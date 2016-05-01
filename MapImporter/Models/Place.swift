//
//  Place.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 10..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

protocol Place {
    var latitude: Double { get }
    var longitude: Double { get }
    var avgRating: Float? { get }
    var avgWaiting: NSTimeInterval? { get }
    var placeInfo: PlaceInfo { get }
}

