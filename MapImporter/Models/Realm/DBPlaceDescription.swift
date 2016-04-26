//
//  DBPlaceDescription.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 26..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

class DBPlaceDescription: Object {
    dynamic var _languageID: String = ""
    dynamic var _text: String = ""
    dynamic var _timestamp: NSDate?
    
    var _placeInfo: DBPlaceInfo {
        return linkingObjects(DBPlaceInfo.self, forProperty: "_descriptions").first!
    }
}

extension DBPlaceDescription: PlaceDescription {
    var languageID: String { return _languageID }
    var text: String { return _text }
    var timestamp: NSDate? { return _timestamp }
    var placeInfo: PlaceInfo { return _placeInfo }
}
