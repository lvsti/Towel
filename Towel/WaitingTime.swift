//
//  WaitingTime.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 17..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

extension NSTimeInterval {
    
    func toString() -> String {
        return (self >= 3600 ? "\(Int(self) / 3600)h " : "") +
            ((Int(self) / 60) % 60 != 0 ? "\((Int(self) / 60) % 60)min" : "")
    }
    
}
