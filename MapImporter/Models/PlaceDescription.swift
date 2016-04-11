//
//  PlaceDescription.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 10..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

protocol PlaceDescription {
    var languageID: String { get }
    var text: String { get }
    var timestamp: NSDate? { get }
    var user: User { get }
    var placeInfo: PlaceInfo { get }
}

class DBPlaceDescription: Object {
    dynamic var _languageID: String = ""
    dynamic var _text: String = ""
    dynamic var _timestamp: NSDate?
    dynamic var _user: DBUser?

    var _placeInfo: DBPlaceInfo {
        return linkingObjects(DBPlaceInfo.self, forProperty: "_descriptions").first!
    }
}

extension DBPlaceDescription: PlaceDescription {
    var languageID: String { return _languageID }
    var text: String { return _text }
    var timestamp: NSDate? { return _timestamp }
    var user: User { return _user! }
    var placeInfo: PlaceInfo { return _placeInfo }
}
