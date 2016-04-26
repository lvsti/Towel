//
//  Query.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 10..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

class Query {
    
    static func getLastImportedPlaceInfo() -> DBPlaceInfo? {
        let realm = try! Realm()
        return realm.objects(DBPlaceInfo).sorted("_placeID", ascending: false).first
    }
    
    static func getLocationForLocality(locality: String?, inCountry countryID: String) -> DBLocation? {
        let realm = try! Realm()
        var predicate: NSPredicate!
        
        if let locality = locality {
            predicate = NSPredicate(format: "_locality == %@ AND _countryID == %@",
                locality,
                countryID)
        } else {
            predicate = NSPredicate(format: "_locality == NULL AND _countryID == %@",
                countryID)
        }
        
        return realm.objects(DBLocation).filter(predicate).first
    }

}
