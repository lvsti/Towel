//
//  ViewController.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 03. 27..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import UIKit
import MapKit

extension Place: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    private var _isModifyingMap: Bool = false
    private let _dataModel: DataModel
    private lazy var _places: [Place] = {
        return try! self._dataModel.getAllPlaces()
    }()
    
    required init?(coder aDecoder: NSCoder) {
        _dataModel = DataModel.instance
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }

    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return MKTileOverlayRenderer(overlay: overlay)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // show/hide annotations based on zoom level
        if mapView.region.span.latitudeDelta < 2 {
            mapView.addAnnotations(_places)
        } else {
            mapView.removeAnnotations(_places)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let place = annotation as? Place {
            let pin = PlacePin(annotation: place, reuseIdentifier: "place")
            pin.configure()
            return pin
        }
        
        return nil
    }
    
}

