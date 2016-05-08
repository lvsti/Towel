//
//  PlacePinView.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 07..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import MapKit

class PlacePinView: MKAnnotationView {
    static let _pinImageNames: [Rating: String] = [
        .Excellent: "pin_exc",
        .Good: "pin_good",
        .Average: "pin_avg",
        .Poor: "pin_poor",
        .Bad: "pin_bad"
    ]
    
    static let _pinImages: [Rating: UIImage] = PlacePinView._pinImageNames
        .fmap { UIImage(named: $0)! }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        canShowCallout = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configure(place: Place) {
        if let avg = place.avgRating {
            let rating = Rating.fromValue(avg)
            image = PlacePinView._pinImages[rating]!
        } else {
            image = UIImage(named: "pin_unknown")
        }
    }
    
    static func titleForPlace(place: Place) -> String {
        let rating = place.avgRating != nil ? Rating.fromValue(place.avgRating!).toString() : "N/A"
        let title = "\u{1F44D}\u{1F3FC} " + rating + "   \u{1F553} " + (place.avgWaiting?.toString() ?? "N/A")
        return title
    }
}
