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
    case MapPolylineSegmentTooLong(MKMapPoint, MKMapPoint)
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

        return pseudoTileForMapPoint(point, atZoomLevel: zoomLevel)
    }
    
    private func pseudoTileForMapPoint(point: MKMapPoint, atZoomLevel zoomLevel: Int) -> TileSpec {
        let tileCount = 1 << zoomLevel
        let coord = TileCoordinate(row: Int(floor(point.y * Double(tileCount) / MKMapSizeWorld.height)),
                                   column: Int(floor(point.x * Double(tileCount) / MKMapSizeWorld.width)))
        
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
    
    func tilesForMapPolyline(polyline: MKPolyline, withPixelRadius pixelRadius: Int, atZoomLevel zoomLevel: Int) throws -> [TileSpec] {
        guard zoomLevel >= 0 && zoomLevel <= TileMapper.maxZoomLevel else {
            throw TileMapperError.InvalidZoomLevel(zoomLevel)
        }

        let mapRadius = mapRadiusFromPixelRadius(pixelRadius, atZoomLevel: zoomLevel)
        let cornerMapRadius = M_SQRT2 * mapRadius

        var tiles = Set<TileSpec>()
        let points = polyline.points()
        
        for i in 0 ..< (polyline.pointCount - 1) {
            // points of the polyline segment
            let startPoint = points.advancedBy(i).memory
            let finishPoint = points.advancedBy(i + 1).memory

            guard startPoint.isValid() else {
                throw TileMapperError.InvalidMapPoint(startPoint)
            }

            guard finishPoint.isValid() else {
                throw TileMapperError.InvalidMapPoint(finishPoint)
            }
            
            // quick and dirty way of ruling out cross-180th-Meridian segments
            guard abs(startPoint.x - finishPoint.x) < MKMapSizeWorld.width / 2.0 else {
                throw TileMapperError.MapPolylineSegmentTooLong(startPoint, finishPoint)
            }

            // slope of the segment (with flipped Y axis)
            let alpha = atan2(-(finishPoint.y - startPoint.y), finishPoint.x - startPoint.x)
            
            // corners of the general position map rectangle that covers the segment
            // extended by `mapRadius` in every direction
            let s1 = MKMapPoint(x: startPoint.x + cornerMapRadius * cos(alpha + M_PI_2 + M_PI_4),
                                y: startPoint.y - cornerMapRadius * sin(alpha + M_PI_2 + M_PI_4))
            let s2 = MKMapPoint(x: startPoint.x + cornerMapRadius * cos(alpha + M_PI + M_PI_4),
                                y: startPoint.y - cornerMapRadius * sin(alpha + M_PI + M_PI_4))
            
            let f1 = MKMapPoint(x: finishPoint.x + cornerMapRadius * cos(alpha + M_PI_4),
                                y: finishPoint.y - cornerMapRadius * sin(alpha + M_PI_4))
            let f2 = MKMapPoint(x: finishPoint.x + cornerMapRadius * cos(alpha - M_PI_4),
                                y: finishPoint.y - cornerMapRadius * sin(alpha - M_PI_4))
            
            let cornerTiles = [
                pseudoTileForMapPoint(s1, atZoomLevel: zoomLevel),
                pseudoTileForMapPoint(s2, atZoomLevel: zoomLevel),
                pseudoTileForMapPoint(f1, atZoomLevel: zoomLevel),
                pseudoTileForMapPoint(f2, atZoomLevel: zoomLevel)
            ]
            
            // tile bounding box coordinates for the corners
            let tileCount = 1 << zoomLevel
            var minCoordinate = TileCoordinate(row: Int.max, column: Int.max)
            var maxCoordinate = TileCoordinate(row: Int.min, column: Int.min)
            
            minCoordinate = cornerTiles
                .reduce(minCoordinate, combine: { (acc, tile) in
                    return TileCoordinate(row: max(0, min(acc.row, tile.coordinate.row)),
                                          column: max(0, min(acc.column, tile.coordinate.column)))
                })

            maxCoordinate = cornerTiles
                .reduce(maxCoordinate, combine: { (acc, tile) in
                    return TileCoordinate(row: min(tileCount - 1, max(acc.row, tile.coordinate.row)),
                                          column: min(tileCount - 1, max(acc.column, tile.coordinate.column)))
                })

            // edges of the general position map rectangle (clockwise)
            let edges = [(s1, f1), (f1, f2), (f2, s2), (s2, s1)]

            // check intersection of bounding box tiles with all 4 edges
            // and collect column ranges for each row for tiles that overlap the map rectangle
            var bucket = [Int: (Int, Int)]()
            
            for row in minCoordinate.row...maxCoordinate.row {
                var columnRange = (Int.max, Int.min)
                
                for column in minCoordinate.column...maxCoordinate.column {
                    let tile = TileSpec(coordinate: TileCoordinate(row: row, column: column), zoomLevel: zoomLevel)
                    
                    for edge in edges {
                        if tile.hasIntersectionWithSegment(from: edge.0, to: edge.1) {
                            if column < columnRange.0 {
                                columnRange.0 = column
                            }
                            if column > columnRange.1 {
                                columnRange.1 = column
                            }
                        }
                    }
                }
                
                bucket[row] = columnRange
            }
            
            for (row, columnRange) in bucket {
                for column in columnRange.0...columnRange.1 {
                    tiles.insert(TileSpec(coordinate: TileCoordinate(row: row, column: column), zoomLevel: zoomLevel))
                }
            }
        }
        
        return Array(tiles)
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
    
    func hasIntersectionWithSegment(from from: MKMapPoint, to: MKMapPoint) -> Bool {
        return mapRect.hasIntersectionWithSegment(from: from, to: to)
    }
    
}

extension MKMapRect {
    
    // https://stackoverflow.com/questions/99353/how-to-test-if-a-line-segment-intersects-an-axis-aligned-rectange-in-2d
    func hasIntersectionWithSegment(from from: MKMapPoint, to: MKMapPoint) -> Bool {
        var minX = min(from.x, to.x)
        var maxX = max(from.x, to.x)
        
        minX = max(minX, MKMapRectGetMinX(self))
        maxX = min(maxX, MKMapRectGetMaxX(self))
        
        if minX > maxX {
            return false
        }
        
        let dx = to.x - from.x
        var yMinX = from.y
        var yMaxX = to.y
        
        if abs(dx) > 0.0000001 {
            let a = (to.y - from.y) / dx
            let b = from.y - a * from.x
            yMinX = a * minX + b
            yMaxX = a * maxX + b
        }
        
        if yMinX > yMaxX {
            swap(&yMinX, &yMaxX)
        }
        
        yMaxX = min(yMaxX, MKMapRectGetMaxY(self))
        yMinX = max(yMinX, MKMapRectGetMinY(self))
        
        if yMinX > yMaxX {
            return false
        }
        
        return true
    }
    
}


