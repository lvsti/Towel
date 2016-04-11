//
//  PlaceComment.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 10..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

protocol PlaceComment {
    var text: String { get }
    var timestamp: NSDate { get }
    var commentID: Int32 { get }
    var user: User { get }
    var placeInfo: PlaceInfo { get }
}

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
    var user: User { return _user! }
    var placeInfo: PlaceInfo { return _placeInfo }
}
