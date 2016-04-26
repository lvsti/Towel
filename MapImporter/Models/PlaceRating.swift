//
//  PlaceRating.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 26..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

enum Rating {
    case Excellent
    case Good
    case Average
    case Poor
    case Bad
    
    static func fromValue(rating: Float) -> Rating {
        switch rating {
        case let x where x > 4.0: return .Excellent
        case let x where x > 3.0: return .Good
        case let x where x > 2.0: return .Average
        case let x where x > 1.0: return .Poor
        default: return .Bad
        }
    }
}


protocol PlaceRating {
    var timestamp: NSDate? { get }
    var value: Rating { get }
    var placeInfo: PlaceInfo { get }
}
