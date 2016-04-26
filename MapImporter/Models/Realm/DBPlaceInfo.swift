//
//  DBPlaceInfo.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 26..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

class DBPlaceInfo: Object {
    dynamic var _placeID: Int32 = 0
    let _altitude = RealmOptional<Double>()
    
    dynamic var _location: DBLocation?
    let _comments = List<DBPlaceComment>()
    let _descriptions = List<DBPlaceDescription>()
    
    var _place: DBPlace {
        return linkingObjects(DBPlace.self, forProperty: "_placeInfo").first!
    }
}

extension DBPlaceInfo: PlaceInfo {
    var placeID: Int32 { return _placeID }
    var altitude: Double? { return _altitude.value }
    
    var location: Location? { return _location }
    var comments: AnyGenerator<PlaceComment> {
        let realmGenerator = _comments.generate()
        return AnyGenerator { return realmGenerator.next() }
    }
    var descriptions: AnyGenerator<PlaceDescription> {
        let realmGenerator = _descriptions.generate()
        return AnyGenerator { return realmGenerator.next() }
    }
    
    var place: Place { return _place }
}

