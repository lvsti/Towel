//
//  TileCache.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 11..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

class TileCacheFactory {
    private let _fileIO: FileIO
    private let _folderIO: FolderIO
    
    private static let _defaultBucketName = "_default"
    private var _defaultCache: TileCache? = nil
    
    init(fileIO: FileIO, folderIO: FolderIO) {
        _fileIO = fileIO
        _folderIO = folderIO
    }
    
    func defaultCache() -> TileCache {
        return disposableCacheForBucket(TileCacheFactory._defaultBucketName)
    }
    
    func disposableCacheForBucket(bucketName: String) -> TileCache {
        return cacheForBucket(bucketName, disposable: true)
    }
    
    func persistentCacheForBucket(bucketName: String) -> TileCache {
        return cacheForBucket(bucketName, disposable: false)
    }
    
    private func cacheForBucket(bucketName: String, disposable: Bool) -> TileCache {
        let directory: NSSearchPathDirectory = disposable ? .CachesDirectory : .ApplicationSupportDirectory
        let containerURL = _folderIO.urlsForDirectory(directory, inDomains: .UserDomainMask).first!
        let folderURL = containerURL
            .URLByAppendingPathComponent("tiles")
            .URLByAppendingPathComponent(bucketName)
        
        return TileCache(rootFolderURL: folderURL, fileIO: _fileIO, folderIO: _folderIO)
    }
}

protocol TileCaching {
    func storeData(data: NSData, forTile tile: TileSpec) throws
    func dataForTile(tile: TileSpec) -> NSData?
    func removeDataForTile(tile: TileSpec) throws
}


class TileCache: TileCaching {
    
    private let _fileIO: FileIO
    private let _folderIO: FolderIO
    private let _rootFolderURL: NSURL
    
    init(rootFolderURL: NSURL, fileIO: FileIO, folderIO: FolderIO) {
        _fileIO = fileIO
        _folderIO = folderIO
        _rootFolderURL = rootFolderURL
    }

    func storeData(data: NSData, forTile tile: TileSpec) throws {
        let url = urlForTile(tile)
        try _fileIO.writeData(data, toURL: url, options: .DataWritingAtomic)
    }
    
    func dataForTile(tile: TileSpec) -> NSData? {
        let url = urlForTile(tile)
        return _fileIO.dataWithContentsOfURL(url)
    }
    
    func removeDataForTile(tile: TileSpec) throws {
        let url = urlForTile(tile)
        try _folderIO.removeItemAtURL(url)
    }
    
    private func urlForTile(tile: TileSpec) -> NSURL {
        let fileName = "\(tile.zoomLevel)_\(tile.coordinate.x)_\(tile.coordinate.y).png"
        return _rootFolderURL.URLByAppendingPathComponent(fileName)
    }
    
}

