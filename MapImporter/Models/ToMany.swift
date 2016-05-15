//
//  ToMany.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 02..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

struct ToMany<T>: CollectionType {
    private let _countFunc: () -> Int
    private let _subscriptFunc: (Int) -> T
    
    init(countFunc: () -> Int, subscriptFunc: (Int) -> T) {
        _countFunc = countFunc
        _subscriptFunc = subscriptFunc
    }
    
    // MARK: - from Indexable
    
    typealias Index = Int
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return _countFunc()
    }
    
    // MARK: - from SequenceType
    
    typealias _Element = T
    
    // MARK: - from CollectionType
    
    subscript (position: Int) -> T {
        return _subscriptFunc(position)
    }
    
    var isEmpty: Bool { return count == 0 }
    var count: Int { return endIndex }
    var first: T? { return count > 0 ? _subscriptFunc(0) : nil }
}

