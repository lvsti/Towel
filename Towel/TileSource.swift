//
//  TileSource.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 16..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

protocol TileSource {
    func urlForTile(tile: TileSpec) -> NSURL
}

