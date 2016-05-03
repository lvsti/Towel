//
//  Query.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 11..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

class Query {
    
    static let config: Realm.Configuration = {
        var config = Realm.Configuration()
        config.path = NSBundle.mainBundle().URLForResource("Towel", withExtension: "realm")!.path
        config.readOnly = true
        return config
    }()
    
    private static func realm() -> Realm {
        return try! Realm(configuration: config)
    }
    
    static func getAllPlaces() -> ToMany<Place> {
        let results = realm().objects(DBPlace)
        return ToMany<Place>(countFunc: { return results.count }, subscriptFunc: { results[$0] })
    }
}
