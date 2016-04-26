//
//  PlaceComment.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 10..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

protocol PlaceComment {
    var text: String { get }
    var timestamp: NSDate { get }
    var placeInfo: PlaceInfo { get }
}

