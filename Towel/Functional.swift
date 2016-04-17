//
//  Functional.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 09..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

extension Dictionary {
    func fmap<T>(transform: (Value) throws -> T) rethrows -> Dictionary<Key, T> {
        return try self.reduce([Key: T](), combine: { (acc, entry) in
            var mutableAcc = acc
            mutableAcc[entry.0] = try transform(entry.1)
            return mutableAcc
        })
    }
}