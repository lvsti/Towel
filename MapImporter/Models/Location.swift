//
//  Location.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 10..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

protocol Location {
    var locality: String? { get }
    var countryID: String { get }
    var continentID: String { get }
}

class DBLocation: Object {
    dynamic var _locality: String?
    dynamic var _countryID: String = ""
    dynamic var _continentID: String = ""
}

extension DBLocation: Location {
    var locality: String? { return _locality }
    var countryID: String { return _countryID }
    var continentID: String { return _continentID }
}
