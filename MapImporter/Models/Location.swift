//
//  Location.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 10..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

protocol Location {
    var locality: String? { get }
    var countryID: String { get }
}
