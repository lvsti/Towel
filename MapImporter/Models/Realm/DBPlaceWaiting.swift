//
//  DBPlaceWaiting.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 26..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

class DBPlaceWaiting: Object {
    dynamic var _timestamp: NSDate?
    dynamic var _minutes: Int32 = 0

    let _placeInfo = LinkingObjects(fromType: DBPlaceInfo.self, property: "_waitings")
}

extension DBPlaceWaiting: PlaceWaiting {
    var timestamp: NSDate? { return _timestamp }
    var time: NSTimeInterval { return Double(_minutes) * 60 }
    
    var placeInfo: PlaceInfo { return _placeInfo.first! }
}
