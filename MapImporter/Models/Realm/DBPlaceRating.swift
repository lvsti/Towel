//
//  DBPlaceRating.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 26..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

class DBPlaceRating: Object {
    dynamic var _timestamp: NSDate?
    dynamic var _value: Int32 = 0

    let _placeInfo = LinkingObjects(fromType: DBPlaceInfo.self, property: "_ratings")
}

extension DBPlaceRating: PlaceRating {
    var timestamp: NSDate? { return _timestamp }
    var value: Rating { return Rating.fromValue(Float(_value)) }
    
    var placeInfo: PlaceInfo { return _placeInfo.first! }
}
