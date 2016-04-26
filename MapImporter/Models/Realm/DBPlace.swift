//
//  DBPlace.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 26..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

class DBPlace: Object {
    dynamic var _latitude: Double = 0.0
    dynamic var _longitude: Double = 0.0
    dynamic var _avgRating: Float = 0.0
    let _avgWaiting = RealmOptional<Float>()
    dynamic var _placeInfo: DBPlaceInfo?
}

extension DBPlace: Place {
    var latitude: Double { return _latitude }
    var longitude: Double { return _longitude }
    var avgRating: Float { return _avgRating }
    var avgWaiting: NSTimeInterval? { return _avgWaiting.value != nil ? Double(_avgWaiting.value!) : nil }
    var placeInfo: PlaceInfo { return _placeInfo! }
}
