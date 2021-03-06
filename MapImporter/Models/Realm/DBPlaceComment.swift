//
//  DBPlaceComment.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 26..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

class DBPlaceComment: Object {
    dynamic var _text: String = ""
    dynamic var _timestamp = NSDate()
    
    let _placeInfo = LinkingObjects(fromType: DBPlaceInfo.self, property: "_comments")
}

extension DBPlaceComment: PlaceComment {
    var text: String { return _text }
    var timestamp: NSDate { return _timestamp }
    var placeInfo: PlaceInfo { return _placeInfo.first! }
}
