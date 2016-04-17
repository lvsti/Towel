//
//  PlaceInfoViewController.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 09..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import UIKit

class PlaceInfoViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var waitingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var ratingCaption: UILabel!
    @IBOutlet weak var waitingCaption: UILabel!
    
    var place: Place!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.toolbarHidden = false
        
        titleLabel.text = titleFromLocation(place.placeInfo.location)
        ratingLabel.text = PlaceRating.fromValue(place.avgRating).toString()
        waitingLabel.text = place.avgWaiting?.toString()
        
        descriptionLabel.text = place.placeInfo.descriptions.next()?.text
    }
    
    private func titleFromLocation(location: Location?) -> String {
        guard let location = location else {
            return "(Unknown location)"
        }
        
        var locStr = ""
        
        if let country = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: location.countryID) {
            locStr = country
        }
        
        if let town = location.locality {
            locStr = town + ", " + locStr
        }
        
        locStr = String.emojiFlagForCountryCode(location.countryID)! + " " + locStr

        return locStr
    }
    
}