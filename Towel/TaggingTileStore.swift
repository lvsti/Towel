//
//  TaggingTileStore.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 16..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation


class TaggingTileStore: TileStorage {
    typealias Tag = String
    
    static let defaultTag: Tag = "default"
    
    private let _store: TileStorage
    private let _fileIO: FileIO
    
    private var _tagsForTile: [TileSpec: Set<Tag>]
    private var _tilesForTag: [Tag: Set<TileSpec>]
    
    private let _tagRegistryURL: NSURL
    
    init(store: TileStorage, fileIO: FileIO, folderIO: FolderIO) {
        _store = store
        _fileIO = fileIO
        _tagsForTile = [:]
        _tilesForTag = [:]
        _tagRegistryURL = folderIO
            .urlsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
            .first!
            .URLByAppendingPathComponent("tags.plist")
        
        loadTags()
    }
    
    private func setTag(tag: Tag, forTiles tiles: [TileSpec]) {
        for tile in tiles {
            if var storedTags = _tagsForTile[tile] {
                storedTags.insert(tag)
            } else {
                _tagsForTile[tile] = [tag]
            }
            
            if var storedTiles = _tilesForTag[tag] {
                storedTiles.insert(tile)
            } else {
                _tilesForTag[tag] = [tile]
            }
        }
    }
    
    private func removeTag(tag: Tag, fromTiles tiles: [TileSpec]) {
        for tile in tiles {
            if var storedTags = _tagsForTile[tile] {
                storedTags.remove(tag)
                if storedTags.count == 0 {
                    _tagsForTile.removeValueForKey(tile)
                }
            }
            
            if var storedTiles = _tilesForTag[tag] {
                storedTiles.remove(tile)
                if storedTiles.count == 0 {
                    _tilesForTag.removeValueForKey(tag)
                }
            }
        }
    }
    
    private func tilesForTag(tag: Tag) -> Set<TileSpec> {
        return _tilesForTag[tag] ?? []
    }
    
    private func loadTags() {
        guard let data = _fileIO.dataWithContentsOfURL(_tagRegistryURL) else {
            return
        }
        
        guard let json = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String: [String]] else {
            return
        }
        
        var tilesForTag = [Tag: Set<TileSpec>]()
        var tagsForTile = [TileSpec: Set<Tag>]()
        for entry in json {
            let tag = entry.0
            let tiles: [TileSpec] = entry.1
                .map { TileSpec(string: $0) }
                .filter { $0 != nil }
                .map { $0! }
            tilesForTag[tag] = Set(tiles)
            
            for tile in tiles {
                if var storedTags = tagsForTile[tile] {
                    storedTags.insert(tag)
                } else {
                    tagsForTile[tile] = [tag]
                }
            }
        }
        
        _tilesForTag = tilesForTag
        _tagsForTile = tagsForTile
    }
    
    private func saveTags() throws {
        var json = [String: [String]]()
        for entry in _tilesForTag {
            json[entry.0] = Array(entry.1).map { $0.toString() }
        }
        
        let data = try NSJSONSerialization.dataWithJSONObject(json, options: [])
        try _fileIO.writeData(data, toURL: _tagRegistryURL, options: [])
    }
    
    func storeData(data: NSData, forTile tile: TileSpec, tag: Tag) throws {
        try _store.storeData(data, forTile: tile)
        setTag(tag, forTiles: [tile])
    }
    
    func removeDataForTile(tile: TileSpec, tag: Tag) throws {
        removeTag(tag, fromTiles: [tile])
        
        if _tagsForTile[tile]?.count == 0 {
            try _store.removeDataForTile(tile)
        }
    }
    
    // MARK: - from ReadOnlyTileStorage
    
    func hasDataForTile(tile: TileSpec) -> Bool {
        return _store.hasDataForTile(tile)
    }
    
    func dataForTile(tile: TileSpec) -> NSData? {
        return _store.dataForTile(tile)
    }
    
    func sizeForTile(tile: TileSpec) -> UInt64? {
        return _store.sizeForTile(tile)
    }
    
    // MARK: - from TileStorage
    
    func storeData(data: NSData, forTile tile: TileSpec) throws {
        try storeData(data, forTile: tile, tag: TaggingTileStore.defaultTag)
    }
    
    func removeDataForTile(tile: TileSpec) throws {
        try removeDataForTile(tile, tag: TaggingTileStore.defaultTag)
    }
    
}
