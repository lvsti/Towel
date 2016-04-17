//
//  PlacePinView.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 07..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import MapKit

enum PinType {
    case Excellent
    case Good
    case Average
    case Poor
    case Bad
    
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

class PlacePinView: MKAnnotationView {
    static let _pinImageNames: [PinType: String] = [
        .Excellent: "pin_exc",
        .Good: "pin_good",
        .Average: "pin_avg",
        .Poor: "pin_poor",
        .Bad: "pin_bad"
    ]
    
    static let _ratingDescKeys: [PinType: String] = [
        .Excellent: "Excellent",
        .Good: "Good",
        .Average: "Average",
        .Poor: "Poor",
        .Bad: "Bad"
    ]
    
    static let _pinImages: [PinType: UIImage] = PlacePinView._pinImageNames
        .fmap { UIImage(named: $0)! }
    
    static var _calloutView: PlacePinCalloutView = {
        let nib = UINib(nibName: "PlacePinCalloutView", bundle: nil)
        return nib.instantiateWithOwner(nil, options: nil).first as! PlacePinCalloutView
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        leftCalloutAccessoryView = PlacePinView._calloutView
        rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        canShowCallout = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configure() {
        let placeAnnotation = annotation as! PlaceAnnotation
        let place = placeAnnotation.place
        let type = PinType.fromRating(place.avgRating)
        image = PlacePinView._pinImages[type]!
        
        NSLog("configure")

        guard selected else {
            return
        }

        let callout = PlacePinView._calloutView
        callout.locationLabel?.text = place.placeInfo.location?.locality
        callout.flagImage?.image = UIImage(named: "flag_\(place.placeInfo.location?.countryID)")
        callout.ratingLabel?.text = PlacePinView._ratingDescKeys[type]
        
        if let minutes = place.avgWaiting {
            callout.waitingLabel?.text = (minutes >= 60 ? "\(minutes / 60)h " : "") + (minutes % 60 != 0 ? "\(minutes % 60)min" : "")
        } else {
            callout.waitingLabel?.text = "N/A"
        }
    }
}
