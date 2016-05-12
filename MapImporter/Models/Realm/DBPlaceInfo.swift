//
//  DBPlaceInfo.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 26..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

class DBPlaceInfo: Object {
    dynamic var _placeID: Int32 = 0
    let _altitude = RealmOptional<Double>()
    
    dynamic var _location: DBLocation?
    let _comments = List<DBPlaceComment>()
    let _descriptions = List<DBPlaceDescription>()
    let _ratings = List<DBPlaceRating>()
    let _waitings = List<DBPlaceWaiting>()

    let _place = LinkingObjects(fromType: DBPlace.self, property: "_placeInfo")
}

extension DBPlaceInfo: PlaceInfo {
    var placeID: Int32 { return _placeID }
    var altitude: Double? { return _altitude.value }
    
    var location: Location? { return _location }
    
    var comments: ToMany<PlaceComment> {
        return ToMany<PlaceComment>(
            countFunc: { return self._comments.count },
            subscriptFunc: { self._comments[$0] }
        )
    }
    
    var descriptions: ToMany<PlaceDescription> {
        return ToMany<PlaceDescription>(
            countFunc: { return self._descriptions.count },
            subscriptFunc: { self._descriptions[$0] }
        )
    }

    var ratings: ToMany<PlaceRating> {
        return ToMany<PlaceRating>(
            countFunc: { return self._ratings.count },
            subscriptFunc: { self._ratings[$0] }
        )
    }

    var waitings: ToMany<PlaceWaiting> {
        return ToMany<PlaceWaiting>(
            countFunc: { return self._waitings.count },
            subscriptFunc: { self._waitings[$0] }
        )
    }

    var place: Place { return _place.first! }
}

