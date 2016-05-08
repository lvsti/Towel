//
//  OSMTileOverlay.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 08..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import MapKit

class OSMTileOverlay: MKTileOverlay {
    
    static let tileURLTemplates = [
        "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
        "https://b.tile.openstreetmap.org/{z}/{x}/{y}.png",
        "https://c.tile.openstreetmap.org/{z}/{x}/{y}.png"
    ]
    
    init() {
        super.init(URLTemplate: nil)
        
        canReplaceMapContent = true
        
        // OSM Tile Usage Policy forbids heavy use of zoom levels 17 and above
        maximumZ = 16
    }

    override func URLForTilePath(path: MKTileOverlayPath) -> NSURL {
        let template = OSMTileOverlay.tileURLTemplates[Int(rand()) % OSMTileOverlay.tileURLTemplates.count]
        let urlString = template
            .stringByReplacingOccurrencesOfString("{x}", withString: "\(path.x)")
            .stringByReplacingOccurrencesOfString("{y}", withString: "\(path.y)")
            .stringByReplacingOccurrencesOfString("{z}", withString: "\(path.z)")

        return NSURL(string: urlString)!
    }
    
}
