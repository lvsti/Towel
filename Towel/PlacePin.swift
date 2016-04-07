//
//  PlacePin.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 07..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import MapKit

enum PinType: String {
    case Excellent = "pin_exc"
    case Good = "pin_good"
    case Average = "pin_avg"
    case Poor = "pin_poor"
    case Bad = "pin_bad"
    
    static func fromRating(rating: Float) -> PinType {
        switch rating {
        case let x where x > 4.0: return .Excellent
        case let x where x > 3.0: return .Good
        case let x where x > 2.0: return .Average
        case let x where x > 1.0: return .Poor
        default: return .Bad
        }
    }
}

class PlacePin: MKAnnotationView {
    static let pinImages: [PinType: UIImage] = [
        .Excellent: UIImage(named: PinType.Excellent.rawValue)!,
        .Good: UIImage(named: PinType.Good.rawValue)!,
        .Average: UIImage(named: PinType.Average.rawValue)!,
        .Poor: UIImage(named: PinType.Poor.rawValue)!,
        .Bad: UIImage(named: PinType.Bad.rawValue)!
    ]

    func configure() {
        let place = annotation as! Place
        let type = PinType.fromRating(place.avgRating)
        image = PlacePin.pinImages[type]!
    }
}
