//
//  AppDelegate.swift
//  MapImporter
//
//  Created by Tamas Lustyik on 2016. 03. 27..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let dbController: DBController
    var window: UIWindow?
    
    lazy var dateFormatter: NSDateFormatter = {
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return fmt
    }()
    
    override init() {
        dbController = DBController.instance
        super.init()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        dispatch_async(dispatch_get_main_queue(), importPlaces)
        
        return true
    }
    
    func importPlaces() {
        let mgr = NSFileManager.defaultManager()
        let placesDirURL = NSBundle.mainBundle().resourceURL!.URLByAppendingPathComponent("places")
        let placeFiles = try! mgr.contentsOfDirectoryAtPath(placesDirURL.path!)
        
        let lastImportedID = "\(lookUpLastImportedPlaceInfo()?.placeID ?? 0)"
        
        var counter = 0
        
        (placeFiles as [String]).forEach { filePath in
            if (filePath as NSString).pathExtension != "json" ||
                ((filePath as NSString).lastPathComponent as NSString).stringByDeletingPathExtension <= lastImportedID {
                return
            }
            
            let placeData = NSData(contentsOfURL: placesDirURL.URLByAppendingPathComponent(filePath))
            let place: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(placeData!, options: []) as! NSDictionary
            NSLog("processing %@", (filePath as NSString).lastPathComponent)
            processPlace(place)
            
            counter += 1
            if counter == 10 {
                dbController.saveContext()
                counter = 0
            }
        }
        dbController.saveContext()
    }
    
    func lookUpLastImportedPlaceInfo() -> PlaceInfo? {
        let request = NSFetchRequest(entityName: "PlaceInfo")
        request.sortDescriptors = [NSSortDescriptor(key: "placeID", ascending: false)]
        request.fetchLimit = 1
        let results = try! dbController.managedObjectContext.executeFetchRequest(request)
        
        return results.count > 0 ? results.first as? PlaceInfo : nil
    }

    func processPlace(json: NSDictionary) {
        let place = NSEntityDescription.insertNewObjectForEntityForName("Place",
            inManagedObjectContext: dbController.managedObjectContext) as! Place
        place.latitude = json["lat"]!.doubleValue
        place.longitude = json["lon"]!.doubleValue
        place.avgRating = json["rating"]!.floatValue

        let info = NSEntityDescription.insertNewObjectForEntityForName("PlaceInfo",
            inManagedObjectContext: dbController.managedObjectContext) as! PlaceInfo
        if let link = json["link"] as? String {
            info.link = link
        }
        info.placeID = Int32(json["id"] as! String)!
        if let alt = json["elevation"]?.doubleValue {
            info.altitude = alt
        }
        
        if let stats = json["waiting_stats"] as? NSDictionary {
            info.waitingCount = Int16(stats["count"] as! String)!
            info.avgWaitingMinutes = stats["avg"] as? NSNumber
        }
        info.place = place
        
        if let comments = json["comments"] as? [NSDictionary] where comments.count > 0 {
            let placeComments = NSMutableSet(capacity: comments.count)
            comments.forEach { comment in
                let placeComment = NSEntityDescription.insertNewObjectForEntityForName("PlaceComment",
                    inManagedObjectContext: dbController.managedObjectContext) as! PlaceComment
                placeComment.commentID = Int32(comment["id"] as! String)!
                placeComment.text = comment["comment"] as! String
                if let datetime = comment["datetime"] as? String {
                    placeComment.timestamp = parseDate(datetime)!
                }
                placeComment.user = processUser(comment["user"] as? NSDictionary)
                placeComment.placeInfo = info
                
                placeComments.addObject(placeComment)
            }
            info.comments = placeComments
        }
        
        info.location = processLocation(json["location"] as? NSDictionary)
        
        if let descriptions = json["description"] as? [String: AnyObject] where descriptions.count > 0 {
            let placeDescriptions = NSMutableSet(capacity: descriptions.count)
            descriptions.forEach { (langID: String, anyDesc: AnyObject) in
                let desc = anyDesc as! NSDictionary
                let placeDesc = NSEntityDescription.insertNewObjectForEntityForName("PlaceDescription",
                    inManagedObjectContext: dbController.managedObjectContext) as! PlaceDescription
                placeDesc.languageID = langID
                placeDesc.text = desc["description"] as! String
                if let datetime = desc["datetime"] as? String {
                    placeDesc.timestamp = parseDate(datetime)!
                }
                if let user = desc["fk_user"] as? String {
                    placeDesc.user = lookUpUser(Int32(user)!)
                }
                placeDesc.placeInfo = info
                
                placeDescriptions.addObject(placeDesc)
            }
            info.descriptions = placeDescriptions
        }
        
        info.user = processUser(json["user"] as? NSDictionary)

        place.placeInfo = info
    }
    
    func parseDate(str: String) -> NSDate? {
        return dateFormatter.dateFromString(str)
    }
    
    func processUser(json: NSDictionary?) -> User? {
        guard
            let json = json,
            let userIDStr = json["id"] as? String
        else {
            return nil
        }
        
        let userID = Int32(userIDStr)!
        if let user = lookUpUser(userID) {
            return user
        }
        
        let user = NSEntityDescription.insertNewObjectForEntityForName("User",
            inManagedObjectContext: dbController.managedObjectContext) as! User
        user.userID = userID
        user.username = json["name"] as! String
        return user
    }
    
    func lookUpUser(id: Int32) -> User? {
        let request = NSFetchRequest(entityName: "User")
        request.predicate = NSPredicate(format: "userID == %d", id)
        let results = try! dbController.managedObjectContext.executeFetchRequest(request)
        
        return results.count > 0 ? results.first as? User : nil
    }
    
    func processLocation(json: NSDictionary?) -> Location? {
        guard let json = json else {
            return nil
        }
        
        let locality = json["locality"] as? String
        let countryID = (json["country"] as! NSDictionary)["iso"] as! String
        if let location = lookUpLocation(locality, inCountry: countryID) {
            return location
        }
        
        let location = NSEntityDescription.insertNewObjectForEntityForName("Location",
            inManagedObjectContext: dbController.managedObjectContext) as! Location
        location.locality = locality
        location.countryID = countryID
        location.continentID = (json["continent"] as! NSDictionary)["code"] as! String
        
        return location
    }
    
    func lookUpLocation(locality: String?, inCountry countryID: String) -> Location? {
        let request = NSFetchRequest(entityName: "Location")
        if let locality = locality {
            request.predicate = NSPredicate(format: "locality == %@ AND countryID == %@",
                locality,
                countryID)
        } else {
            request.predicate = NSPredicate(format: "locality == NULL AND countryID == %@",
                countryID)
        }
        let results = try! dbController.managedObjectContext.executeFetchRequest(request)
        
        return results.count > 0 ? results.first as? Location : nil
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        dbController.saveContext()
    }

}

