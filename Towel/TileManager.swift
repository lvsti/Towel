//
//  TileManager.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 11..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import Alamofire

class TileManager {
    
    private let _store: TaggingTileStore
    
    init(store: TaggingTileStore) {
        _store = store
    }
    
    func downloadTiles(tiles: [TileSpec],
                       fromSource source: TileSource,
                       withTag tag: TaggingTileStore.Tag = TaggingTileStore.defaultTag) {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("me.cocoagrinder.Towel")
        let manager = Alamofire.Manager(configuration: configuration)
        
        for tile in tiles {
            manager
                .request(.GET, source.urlForTile(tile))
                .responseData { response in
                    if let data = response.data {
                        do {
                            try self._store.storeData(data, forTile: tile, tag: tag)
                        }
                        catch {
                        }
                    }
                }
        }
    }
    
}
