//
//  AppDelegate.swift
//  MapImporter
//
//  Created by Tamas Lustyik on 2016. 04. 10..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Cocoa
import RealmSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    let fileManager: NSFileManager
    
    override init() {
        fileManager = NSFileManager.defaultManager()
        super.init()
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        dispatch_async(dispatch_get_main_queue(), importPlacesFromAPIDB)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func importPlacesFromAPIDB() {
        let placesDirURL = NSURL(fileURLWithPath: "/Users/lvsti/tw/places/")
        let placeFiles = try! fileManager.contentsOfDirectoryAtPath(placesDirURL.path!)
        
        let lastImportedID = "\(Query.getLastImportedPlaceInfo()?.placeID ?? 0)"
        
        var counter = 0
        let realm = try! Realm()
        realm.beginWrite()
        
        (placeFiles as [String]).forEach { filePath in
            if (filePath as NSString).pathExtension != "json" ||
                ((filePath as NSString).lastPathComponent as NSString).stringByDeletingPathExtension <= lastImportedID {
                return
            }
            
            let placeData = NSData(contentsOfURL: placesDirURL.URLByAppendingPathComponent(filePath))
            let place: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(placeData!, options: []) as! NSDictionary
            NSLog("processing %@", (filePath as NSString).lastPathComponent)
            let dbPlace = processPlace(place)
            realm.add(dbPlace)
            
            counter += 1
            if counter == 10 {
                try! realm.commitWrite()
                counter = 0
                realm.beginWrite()
            }
        }
        try! realm.commitWrite()
    }
    
    func processPlace(json: NSDictionary) -> DBPlace {
        let place = DBPlace()
        place._latitude = json["lat"]!.doubleValue
        place._longitude = json["lon"]!.doubleValue
        if let exactRating = (json["rating_stats"]?["exact_rating"] as? NSNumber)?.floatValue {
            place._avgRating = exactRating
        } else {
            place._avgRating = json["rating"]!.floatValue
        }
        
        if let stats = json["waiting_stats"] as? NSDictionary,
           let avg = stats["avg"] as? NSNumber {
            place._avgWaiting.value = avg.floatValue * 60
        }

        let info = DBPlaceInfo()
        info._placeID = Int32(json["id"] as! String)!
        if let alt = json["elevation"]?.doubleValue {
            info._altitude.value = alt
        }
        
        if let comments = json["comments"] as? [NSDictionary] where comments.count > 0 {
            comments.forEach { comment in
                let placeComment = DBPlaceComment()
                placeComment._commentID = Int32(comment["id"] as! String)!
                placeComment._text = comment["comment"] as! String
                if let datetime = comment["datetime"] as? String {
                    placeComment._timestamp = parseDate(datetime)!
                }
                
                info._comments.append(placeComment)
            }
        }
        
        info._location = processLocation(json["location"] as? NSDictionary)
        
        if let descriptions = json["description"] as? [String: AnyObject] where descriptions.count > 0 {
            descriptions.forEach { (langID: String, anyDesc: AnyObject) in
                let desc = anyDesc as! NSDictionary
                let placeDesc = DBPlaceDescription()
                placeDesc._languageID = langID
                placeDesc._text = desc["description"] as! String
                if let datetime = desc["datetime"] as? String {
                    placeDesc._timestamp = parseDate(datetime)!
                }
                
                info._descriptions.append(placeDesc)
            }
        }
        
        place._placeInfo = info
        
        return place
    }
    
    func parseDate(str: String) -> NSDate? {
        return dateFormatter.dateFromString(str)
    }
    
    func processLocation(json: NSDictionary?) -> DBLocation? {
        guard let json = json else {
            return nil
        }
        
        let locality = json["locality"] as? String
        let countryID = (json["country"] as! NSDictionary)["iso"] as! String
        if let location = Query.getLocationForLocality(locality, inCountry: countryID) {
            return location
        }
        
        let location = DBLocation()
        location._locality = locality
        location._countryID = countryID
        location._continentID = (json["continent"] as! NSDictionary)["code"] as! String
        
        return location
    }

    lazy var dateFormatter: NSDateFormatter = {
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return fmt
    }()
    
}

