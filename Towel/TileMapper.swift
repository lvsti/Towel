//
//  TileMapper.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 10..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import MapKit

struct TileCoordinate {
    let x: Int
    let y: Int
}

struct TileSpec {
    let coordinate: TileCoordinate
    let zoomLevel: Int
}

extension TileSpec {
    init(path: MKTileOverlayPath) {
        coordinate = TileCoordinate(x: path.x, y: path.y)
        zoomLevel = path.z
    }
}

enum TileMapperError: ErrorType {
    case InvalidZoomLevel(Int)
    case InvalidMapPoint(MKMapPoint)
}


class TileMapper {
    
    static let maxZoomLevel: Int = 20
    static let tileSize: Double = 256.0
    
    func tileForMapPoint(point: MKMapPoint, atZoomLevel zoomLevel: Int) throws -> TileSpec {
        guard zoomLevel >= 0 && zoomLevel <= TileMapper.maxZoomLevel else {
            throw TileMapperError.InvalidZoomLevel(zoomLevel)
        }
        
        guard point.x >= 0 && point.x < MKMapSizeWorld.width && point.y >= 0 && point.y < MKMapSizeWorld.height else {
            throw TileMapperError.InvalidMapPoint(point)
        }

        let u = point.x/MKMapSizeWorld.width
        let v = point.y/MKMapSizeWorld.height

        let tileCount = 1 << zoomLevel
        let coord = TileCoordinate(x: Int(u * Double(tileCount)),
                                   y: Int(v * Double(tileCount)))
        
        return TileSpec(coordinate: coord, zoomLevel: zoomLevel)
    }
    
    func tilesForMapRegionWithCenter(center: MKMapPoint, pixelRadius: Int, atZoomLevel zoomLevel: Int) throws -> [TileSpec] {
        guard zoomLevel >= 0 && zoomLevel <= TileMapper.maxZoomLevel else {
            throw TileMapperError.InvalidZoomLevel(zoomLevel)
        }
        
        guard center.x >= 0 && center.x < MKMapSizeWorld.width && center.y >= 0 && center.y < MKMapSizeWorld.height else {
            throw TileMapperError.InvalidMapPoint(center)
        }
        
        let pointsPerTile = MKMapSizeWorld.width / pow(2.0, Double(zoomLevel))
        let pointsPerPixel = pointsPerTile / TileMapper.tileSize
        let mapRadius = Double(pixelRadius) * pointsPerPixel
        
        let rect = MKMapRectMake(center.x - mapRadius, center.y - mapRadius, 2*mapRadius, 2*mapRadius)
        let tileCount = 1 << zoomLevel

        let top = Int(floor(Double(tileCount) * max(0, MKMapRectGetMinY(rect)) / MKMapSizeWorld.height))
        let left = Int(floor(Double(tileCount) * max(0, MKMapRectGetMinX(rect)) / MKMapSizeWorld.width))
        let bottom = Int(floor(Double(tileCount) * min(MKMapSizeWorld.height - 1, MKMapRectGetMaxY(rect)) / MKMapSizeWorld.height))
        let right = Int(floor(Double(tileCount) * min(MKMapSizeWorld.width - 1, MKMapRectGetMaxX(rect)) / MKMapSizeWorld.width))

        var tiles = [TileSpec]()
        
        for y in top...bottom {
            for x in left...right {
                let tile = TileSpec(coordinate: TileCoordinate(x: x, y: y), zoomLevel: zoomLevel)
                tiles.append(tile)
            }
        }
        
        return tiles
    }
    
}
