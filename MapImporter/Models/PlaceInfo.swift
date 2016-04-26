//
//  PlaceInfo.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 10..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

protocol PlaceInfo {
    var placeID: Int32 { get }
    var altitude: Double? { get }
    
    var location: Location? { get }
    var comments: AnyGenerator<PlaceComment> { get }
    var descriptions: AnyGenerator<PlaceDescription> { get }
    var user: User { get }
    
    var place: Place { get }
}

