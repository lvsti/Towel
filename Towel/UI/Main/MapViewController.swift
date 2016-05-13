//
//  MapViewController.swift
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

class MapViewController: UIViewController, MKMapViewDelegate, FBClusteringManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    private let _clusteringManager: FBClusteringManager
    private let _tileOverlay: OSMTileOverlay
    
    required init?(coder aDecoder: NSCoder) {
        _clusteringManager = FBClusteringManager(annotations: [])
        _tileOverlay = OSMTileOverlay()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.showOSMAttribution()
        mapView.addOverlay(_tileOverlay, level: .AboveLabels)
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard
            segue.identifier == "showPlaceInfo",
            let infoVC = segue.destinationViewController as? PlaceInfoViewController ??
                (segue.destinationViewController as? UINavigationController)?.topViewController as? PlaceInfoViewController,
            let annotation = (sender as? MKAnnotationView)?.annotation as? PlaceAnnotation
        else {
            return
        }
        
        infoVC.place = annotation.place
        infoVC.mapOverlay = _tileOverlay
        infoVC.mapSpan = MKCoordinateSpan(latitudeDelta: 0,
                                          longitudeDelta: mapView.region.span.longitudeDelta)
    }
    
    @IBAction func unwindPlaceInfo(unwindSegue: UIStoryboardSegue) {
        
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
            let pin = mapView.dequeueReusableAnnotationViewWithIdentifier("place") as? PlacePinView ??
                PlacePinView(annotation: place, reuseIdentifier: "place")
            pin.configure(place.place)
            return pin
        }
        else if let cluster = annotation as? FBAnnotationCluster {
            let pin = mapView.dequeueReusableAnnotationViewWithIdentifier("cluster") as? ClusterPinView ??
                ClusterPinView(annotation: cluster, reuseIdentifier: "cluster")
            pin.count = UInt(cluster.annotations.count)
            return pin
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier("showPlaceInfo", sender: view)
    }
    
}
