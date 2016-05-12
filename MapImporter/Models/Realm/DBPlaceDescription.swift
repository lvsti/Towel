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
    
    let _placeInfo = LinkingObjects(fromType: DBPlaceInfo.self, property: "_descriptions")
}

extension DBPlaceDescription: PlaceDescription {
    var languageID: String { return _languageID }
    var text: String { return _text }
    var timestamp: NSDate? { return _timestamp }
    var placeInfo: PlaceInfo { return _placeInfo.first! }
}
