//
//  OSMTileOverlay.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 08..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import MapKit

struct OSMTileSource: TileSource {
    private static let tileURLTemplates = [
        "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
        "https://b.tile.openstreetmap.org/{z}/{x}/{y}.png",
        "https://c.tile.openstreetmap.org/{z}/{x}/{y}.png"
    ]
    
    func urlForTile(tile: TileSpec) -> NSURL {
        let template = OSMTileSource.tileURLTemplates[Int(rand()) % OSMTileSource.tileURLTemplates.count]
        let urlString = template
            .stringByReplacingOccurrencesOfString("{x}", withString: "\(tile.coordinate.x)")
            .stringByReplacingOccurrencesOfString("{y}", withString: "\(tile.coordinate.y)")
            .stringByReplacingOccurrencesOfString("{z}", withString: "\(tile.zoomLevel)")
        return NSURL(string: urlString)!
    }
}

class OSMTileOverlay: MKTileOverlay {
    
    private let _tileStore: ReadOnlyTileStorage
    private let _tileSource: TileSource
    
    init(tileStore: ReadOnlyTileStorage, tileSource: TileSource) {
        _tileStore = tileStore
        _tileSource = tileSource
        super.init(URLTemplate: nil)
        
        canReplaceMapContent = true
        
        // OSM Tile Usage Policy forbids heavy use of zoom levels 17 and above
        maximumZ = 16
    }

    override func URLForTilePath(path: MKTileOverlayPath) -> NSURL {
        return _tileSource.urlForTile(TileSpec(path: path))
    }
    
    override func loadTileAtPath(path: MKTileOverlayPath, result: (NSData?, NSError?) -> Void) {
        let tile = TileSpec(path: path)
        if let data = _tileStore.dataForTile(tile) {
            result(data, nil)
            return
        }
        
        super.loadTileAtPath(path, result: result)
    }
    
}
