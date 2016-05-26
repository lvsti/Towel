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
    let row: Int
    let column: Int
}

extension TileCoordinate: Equatable {}

extension TileCoordinate: Hashable {
    var hashValue: Int { return "\(row)_\(column)".hashValue }
}

func ==(lhs: TileCoordinate, rhs: TileCoordinate) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}

struct TileSpec {
    let coordinate: TileCoordinate
    let zoomLevel: Int
}

extension TileSpec {
    init(path: MKTileOverlayPath) {
        coordinate = TileCoordinate(row: path.y, column: path.x)
        zoomLevel = path.z
    }
}

extension TileSpec: Equatable {}

func ==(lhs: TileSpec, rhs: TileSpec) -> Bool {
    return lhs.zoomLevel == rhs.zoomLevel && lhs.coordinate == rhs.coordinate
}

extension TileSpec: Hashable {
    var hashValue: Int { return "\(zoomLevel)_\(coordinate.row)_\(coordinate.column)".hashValue }
}

extension TileSpec {
    init?(string: String) {
        let comps: [Int] = string
            .componentsSeparatedByString("_")
            .map { Int($0) }
            .filter { $0 != nil }
            .map { $0! }
        
        guard comps.count == 3 else {
            return nil
        }
        
        zoomLevel = comps[0]
        coordinate = TileCoordinate(row: comps[1], column: comps[2])
    }

    func toString() -> String {
        return "\(zoomLevel)_\(coordinate.row)_\(coordinate.column)"
    }
}

extension MKMapPoint {
    func isValid() -> Bool {
        return x >= 0 && x < MKMapSizeWorld.width && y >= 0 && y < MKMapSizeWorld.height
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
        
        guard point.isValid() else {
            throw TileMapperError.InvalidMapPoint(point)
        }

        let u = point.x/MKMapSizeWorld.width
        let v = point.y/MKMapSizeWorld.height

        let tileCount = 1 << zoomLevel
        let coord = TileCoordinate(row: Int(v * Double(tileCount)),
                                   column: Int(u * Double(tileCount)))
        
        return TileSpec(coordinate: coord, zoomLevel: zoomLevel)
    }
    
    func tilesForMapRegionWithCenter(center: MKMapPoint, pixelRadius: Int, atZoomLevel zoomLevel: Int) throws -> [TileSpec] {
        guard zoomLevel >= 0 && zoomLevel <= TileMapper.maxZoomLevel else {
            throw TileMapperError.InvalidZoomLevel(zoomLevel)
        }
        
        guard center.isValid() else {
            throw TileMapperError.InvalidMapPoint(center)
        }

        let mapRadius = mapRadiusFromPixelRadius(pixelRadius, atZoomLevel: zoomLevel)
        let rect = MKMapRectMake(center.x - mapRadius, center.y - mapRadius, 2*mapRadius, 2*mapRadius)
        let tileCount = 1 << zoomLevel

        let top = Int(floor(Double(tileCount) * max(0, MKMapRectGetMinY(rect)) / MKMapSizeWorld.height))
        let left = Int(floor(Double(tileCount) * max(0, MKMapRectGetMinX(rect)) / MKMapSizeWorld.width))
        let bottom = Int(floor(Double(tileCount) * min(MKMapSizeWorld.height - 1, MKMapRectGetMaxY(rect)) / MKMapSizeWorld.height))
        let right = Int(floor(Double(tileCount) * min(MKMapSizeWorld.width - 1, MKMapRectGetMaxX(rect)) / MKMapSizeWorld.width))

        var tiles = [TileSpec]()
        
        for row in top...bottom {
            for column in left...right {
                let tile = TileSpec(coordinate: TileCoordinate(row: row, column: column), zoomLevel: zoomLevel)
                tiles.append(tile)
            }
        }
        
        return tiles
    }
    
    private func mapRadiusFromPixelRadius(pixelRadius: Int, atZoomLevel zoomLevel: Int) -> Double {
        let pointsPerTile = MKMapSizeWorld.width / pow(2.0, Double(zoomLevel))
        let pointsPerPixel = pointsPerTile / TileMapper.tileSize
        return Double(pixelRadius) * pointsPerPixel
    }
    
}


extension TileSpec {
    
    var mapRect: MKMapRect {
        let pointsPerTile = MKMapSizeWorld.width / pow(2.0, Double(zoomLevel))
        return MKMapRect(origin: MKMapPoint(x: pointsPerTile * Double(coordinate.column), y: pointsPerTile * Double(coordinate.row)),
                         size: MKMapSize(width: pointsPerTile, height: pointsPerTile))
    }
    
}
