//
//  TileCache.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 11..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation


class PersistentTileStore: TileStorage {
    
    private let _fileIO: FileIO
    private let _folderIO: FolderIO
    private let _rootFolderURL: NSURL
    
    init(rootFolderURL: NSURL, fileIO: FileIO, folderIO: FolderIO) {
        _fileIO = fileIO
        _folderIO = folderIO
        _rootFolderURL = rootFolderURL
    }
    
    func hasDataForTile(tile: TileSpec) -> Bool {
        let url = urlForTile(tile)
        return _folderIO.itemExistsAtURL(url)
    }

    func dataForTile(tile: TileSpec) -> NSData? {
        let url = urlForTile(tile)
        return _fileIO.dataWithContentsOfURL(url)
    }
    
    func sizeForTile(tile: TileSpec) -> UInt64? {
        let url = urlForTile(tile)
        return try? _folderIO.sizeOfItemAtURL(url)
    }
    
    func storeData(data: NSData, forTile tile: TileSpec) throws {
        let url = urlForTile(tile)
        try _fileIO.writeData(data, toURL: url, options: .DataWritingAtomic)
    }
    
    func removeDataForTile(tile: TileSpec) throws {
        let url = urlForTile(tile)
        try _folderIO.removeItemAtURL(url)
    }
    
    private func urlForTile(tile: TileSpec) -> NSURL {
        let fileName = "\(tile.zoomLevel)_\(tile.coordinate.row)_\(tile.coordinate.column).png"
        return _rootFolderURL.URLByAppendingPathComponent(fileName)
    }
    
}

