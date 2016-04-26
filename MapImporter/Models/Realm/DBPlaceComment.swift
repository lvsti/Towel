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
    dynamic var _commentID: Int32 = 0
    
    dynamic var _user: DBUser?
    
    var _placeInfo: DBPlaceInfo {
        return linkingObjects(DBPlaceInfo.self, forProperty: "_comments").first!
    }
}

extension DBPlaceComment: PlaceComment {
    var text: String { return _text }
    var timestamp: NSDate { return _timestamp }
    var commentID: Int32 { return _commentID }
    var placeInfo: PlaceInfo { return _placeInfo }
}
