//
//  Rating.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 17..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

extension Rating {
    func toString() -> String {
        return [
            .Excellent: "Excellent",
            .Good: "Good",
            .Average: "Average",
            .Poor: "Poor",
            .Bad: "Bad"
        ][self]!
    }
}
