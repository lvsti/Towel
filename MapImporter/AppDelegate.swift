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
        dispatch_async(dispatch_get_main_queue(), importPlaces)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func importPlaces() {
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
            let dbPlace = processPlaceFromSiteDB(place)
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

    func processPlaceFromSiteDB(json: NSDictionary) -> DBPlace {
        let place = DBPlace()
        
        place._latitude = json["lat"]!.doubleValue
        place._longitude = json["lon"]!.doubleValue
        
        let info = DBPlaceInfo()
        info._placeID = json["id"]!.intValue
        if let alt = json["elevation"]?.doubleValue {
            info._altitude.value = alt
        }
        
        if let comments = json["comments"] as? [NSDictionary] where comments.count > 0 {
            comments.forEach { comment in
                let placeComment = DBPlaceComment()
                placeComment._text = comment["text"] as! String
                if let timestamp = comment["timestamp"] as? String {
                    placeComment._timestamp = parseSiteDate(timestamp)!
                }
                
                info._comments.append(placeComment)
            }
        }

        let ratingStats = json["rating_stats"] as! NSDictionary
        if let avg = ratingStats["avg_rating"]?.floatValue where avg > 0 {
            place._avgRating.value = avg

            if let ratings = ratingStats["ratings"] as? [NSDictionary] where ratings.count > 0 {
                ratings.forEach { rating in
                    let placeRating = DBPlaceRating()
                    placeRating._value = rating["value"]!.intValue
                    if let timestamp = rating["timestamp"] as? String {
                        placeRating._timestamp = parseSiteDate(timestamp)!
                    }
                    
                    info._ratings.append(placeRating)
                }
            }
        }
        
        let waitingStats = json["waiting_stats"] as! NSDictionary
        if let minutes = (waitingStats["avg_waiting_minutes"] as? NSNumber)?.doubleValue {
            place._avgWaiting.value = Float(minutes) * 60
        }
        
        if let waitings = waitingStats["waitings"] as? [NSDictionary] where waitings.count > 0 {
            waitings.forEach { waiting in
                let placeWaiting = DBPlaceWaiting()
                placeWaiting._minutes = waiting["minutes"]!.intValue
                if let timestamp = waiting["timestamp"] as? String {
                    placeWaiting._timestamp = parseSiteDate(timestamp)!
                }
                
                info._waitings.append(placeWaiting)
            }
        }

        info._location = processSiteLocation(json["location"] as? NSDictionary)
        
        if let descriptions = json["descriptions"] as? [String: NSDictionary] where descriptions.count > 0 {
            descriptions.forEach { (langID: String, desc: NSDictionary) in
                let placeDesc = DBPlaceDescription()
                placeDesc._languageID = langID
                placeDesc._text = desc["text"] as! String
                if let timestamp = desc["timestamp"] as? String {
                    placeDesc._timestamp = parseSiteDate(timestamp)!
                }
                
                info._descriptions.append(placeDesc)
            }
        }
        
        place._placeInfo = info

        return place
    }
    
    func processSiteLocation(json: NSDictionary?) -> DBLocation? {
        guard let json = json else {
            return nil
        }
        
        let locality = json["locality"] as? String
        let countryID = json["country_code"] as! String
        if let location = Query.getLocationForLocality(locality, inCountry: countryID) {
            return location
        }
        
        let location = DBLocation()
        location._locality = locality
        location._countryID = countryID
        
        return location
    }
    
    func parseSiteDate(str: String) -> NSDate? {
        return siteDateFormatter.dateFromString(str)
    }
    
    lazy var siteDateFormatter: NSDateFormatter = {
        let fmt = NSDateFormatter()
        fmt.dateFormat = "EEE, dd MMM yy HH:mm:ss ZZZ"
        fmt.locale = NSLocale(localeIdentifier: "en")
        return fmt
    }()
 
    func processPlaceFromAPIDB(json: NSDictionary) -> DBPlace {
        let place = DBPlace()
        place._latitude = json["lat"]!.doubleValue
        place._longitude = json["lon"]!.doubleValue
        if let exactRating = (json["rating_stats"]?["exact_rating"] as? NSNumber)?.floatValue {
            place._avgRating.value = exactRating
        } else {
            place._avgRating.value = json["rating"]!.floatValue
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
                placeComment._text = comment["comment"] as! String
                if let datetime = comment["datetime"] as? String {
                    placeComment._timestamp = parseAPIDate(datetime)!
                }
                
                info._comments.append(placeComment)
            }
        }
        
        info._location = processAPILocation(json["location"] as? NSDictionary)
        
        if let descriptions = json["description"] as? [String: AnyObject] where descriptions.count > 0 {
            descriptions.forEach { (langID: String, anyDesc: AnyObject) in
                let desc = anyDesc as! NSDictionary
                let placeDesc = DBPlaceDescription()
                placeDesc._languageID = langID
                placeDesc._text = desc["description"] as! String
                if let datetime = desc["datetime"] as? String {
                    placeDesc._timestamp = parseAPIDate(datetime)!
                }
                
                info._descriptions.append(placeDesc)
            }
        }
        
        place._placeInfo = info
        
        return place
    }
    
    func parseAPIDate(str: String) -> NSDate? {
        return apiDateFormatter.dateFromString(str)
    }

    func processAPILocation(json: NSDictionary?) -> DBLocation? {
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
        
        return location
    }

    lazy var apiDateFormatter: NSDateFormatter = {
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return fmt
    }()

}

