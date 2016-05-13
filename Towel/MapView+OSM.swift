//
//  MapView+OSM.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 13..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    
    private static let osmLabelTag = 1234
    
    func showOSMAttribution() {
        for subview in subviews {
            if !subview.isKindOfClass(UILabel.self) {
                continue
            }
            
            if subview.tag == MKMapView.osmLabelTag {
                // OSM label already installed
                return
            }
            
            // hide "Legal" button as we are not using Apple Maps data at all
            subview.hidden = true
            break
        }
        
        installOSMLabel()
    }
    
    private func installOSMLabel() {
        let osmLabel = UILabel()
        osmLabel.text = "OpenStreetMap"
        osmLabel.tag = MKMapView.osmLabelTag
        osmLabel.font = UIFont.systemFontOfSize(10)
        osmLabel.frame = CGRect(x: bounds.size.width - 80,
                                y: bounds.size.height - 14,
                                width: 80,
                                height: 14)
        osmLabel.autoresizingMask = [.FlexibleLeftMargin, .FlexibleTopMargin]
        addSubview(osmLabel)
    }
}
