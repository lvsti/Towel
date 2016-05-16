//
//  TileStorage.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 16..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

protocol ReadOnlyTileStorage {
    func hasDataForTile(tile: TileSpec) -> Bool
    func dataForTile(tile: TileSpec) -> NSData?
    func sizeForTile(tile: TileSpec) -> UInt64?
}

protocol TileStorage: ReadOnlyTileStorage {
    func storeData(data: NSData, forTile tile: TileSpec) throws
    func removeDataForTile(tile: TileSpec) throws
}
