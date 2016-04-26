//
//  PlaceWaiting.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 26..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

protocol PlaceWaiting {
    var timestamp: NSDate? { get }
    var time: NSTimeInterval { get }
}
