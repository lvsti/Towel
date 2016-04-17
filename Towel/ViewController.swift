//
//  ViewController.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 03. 27..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import UIKit
import MapKit
import FBAnnotationClustering

class PlaceAnnotation: NSObject, MKAnnotation {
    let place: Place
    init(place: Place) {
        self.place = place
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(place.latitude, place.longitude)
    }
    var title: String? {
        return PlacePinView.titleForPlace(place)
    }
}

class ViewController: UIViewController, MKMapViewDelegate, FBClusteringManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    private let _clusteringManager: FBClusteringManager
    
    required init?(coder aDecoder: NSCoder) {
        _clusteringManager = FBClusteringManager(annotations: [])
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        loadPlaces()        
    }
    
    private func loadPlaces() {
        var places = [PlaceAnnotation]()
        Query.getAllPlaces().forEach { p in
            places.append(PlaceAnnotation(place: p))
        }
        _clusteringManager.setAnnotations(places)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return MKTileOverlayRenderer(overlay: overlay)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let scale = Double(mapView.bounds.size.width) / mapView.visibleMapRect.size.width
        let annotations = _clusteringManager.clusteredAnnotationsWithinMapRect(mapView.visibleMapRect, withZoomScale: scale)
        
        _clusteringManager.displayAnnotations(annotations, onMapView: mapView)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let place = annotation as? PlaceAnnotation {
            let pin = PlacePinView(annotation: place, reuseIdentifier: "place")
            pin.configure()
            return pin
        }
        else if let cluster = annotation as? FBAnnotationCluster {
            let pin = ClusterPinView(annotation: cluster, reuseIdentifier: "cluster")
            pin.count = UInt(cluster.annotations.count)
            return pin
        }
        
        return nil
    }
    
}

