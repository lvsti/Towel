//
//  PlaceAnnotation.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 16..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    let place: Place
    init(place: Place) {
        self.place = place
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(place.latitude, place.longitude)
    }
    var title: String? {
        return PlacePinView.titleForPlace(place)
    }
}

