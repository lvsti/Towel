//
//  PlaceInfoMapCell.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 12..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import MapKit

class PlaceInfoMapCell: UITableViewCell {
    @IBOutlet weak var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mapView.showOSMAttribution()
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTapGesture)
        
        let twoFingerTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTwoFingerTap))
        twoFingerTapGesture.numberOfTouchesRequired = 2
        mapView.addGestureRecognizer(twoFingerTapGesture)
    }
    
    func handleDoubleTap(sender: AnyObject!) {
        var region = mapView.region
        region.span.latitudeDelta *= 0.5
        region.span.longitudeDelta *= 0.5
        mapView.setRegion(region, animated: true)
    }
    
    func handleTwoFingerTap(sender: AnyObject!) {
        var region = mapView.region
        region.span.latitudeDelta *= 2
        region.span.longitudeDelta *= 2
        mapView.setRegion(region, animated: true)
    }
}

