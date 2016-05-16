//
//  PlaceInfoViewController.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 09..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import UIKit
import MapKit

enum PlaceInfoViewRows: Int {
    case Map = 0
    case Title = 1
    case Stats = 2
    case Description = 3
    case CommentsTitle = 4
    case Comments = 5
}

class PlaceInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var place: Place!
    var mapOverlay: MKTileOverlay!
    var mapSpan: MKCoordinateSpan!
    
    let dateFormatter: NSDateFormatter
    
    required init?(coder aDecoder: NSCoder) {
        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
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
    
    @IBAction func streetViewButtonTapped(sender: AnyObject) {
        let streetView = "https://maps.google.com/maps?q=&layer=c&cbll=\(place.latitude),\(place.longitude)"
        UIApplication.sharedApplication().openURL(NSURL(string: streetView)!)
    }
    
    // MARK: - from UITableViewDataSource:
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 +
            (place.placeInfo.descriptions.count > 0 ? 1 : 0) +
            (place.placeInfo.comments.count > 0 ? place.placeInfo.comments.count + 1 : 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == PlaceInfoViewRows.Map.rawValue) {
            let cell = tableView.dequeueReusableCellWithIdentifier("placeInfoMapCell", forIndexPath: indexPath) as! PlaceInfoMapCell
            cell.mapView.delegate = self
            
            cell.mapView.addOverlay(mapOverlay, level: .AboveLabels)
            let center = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            cell.mapView.region = MKCoordinateRegionMakeWithDistance(center, 500, 500)
            
            cell.mapView.addAnnotation(PlaceAnnotation(place: place))

            return cell
        }
        
        if (indexPath.row == PlaceInfoViewRows.Title.rawValue) {
            // title
            let cell = tableView.dequeueReusableCellWithIdentifier("placeInfoTitleCell", forIndexPath: indexPath) as! PlaceInfoTitleCell
            cell.titleLabel.text = titleFromLocation(place.placeInfo.location)
            return cell
        }
        
        if (indexPath.row == PlaceInfoViewRows.Stats.rawValue) {
            // stats
            let cell = tableView.dequeueReusableCellWithIdentifier("placeInfoStatsCell", forIndexPath: indexPath) as! PlaceInfoStatsCell
            cell.ratingLabel.text = place.avgRating != nil ? Rating.fromValue(place.avgRating!).toString() : "N/A"
            cell.waitingLabel.text = place.avgWaiting?.toString() ?? "N/A"
            return cell
        }
        
        let hasDescription = place.placeInfo.descriptions.count > 0
        let commentsRowDelta = hasDescription ? 0 : -1
        
        if (indexPath.row == PlaceInfoViewRows.Description.rawValue && hasDescription) {
            // description
            let cell = tableView.dequeueReusableCellWithIdentifier("placeInfoDescriptionCell", forIndexPath: indexPath) as! PlaceInfoDescriptionCell
            cell.descriptionLabel.text = place.placeInfo.descriptions.first!.text
            return cell
        }
        
        if (indexPath.row == PlaceInfoViewRows.CommentsTitle.rawValue + commentsRowDelta) {
            // comments subtitle
            let cell = tableView.dequeueReusableCellWithIdentifier("placeInfoCommentsTitleCell", forIndexPath: indexPath) as! PlaceInfoCommentsTitleCell
            return cell
        }
        
        if (indexPath.row >= PlaceInfoViewRows.Comments.rawValue + commentsRowDelta) {
            // comments
            let cell = tableView.dequeueReusableCellWithIdentifier("placeInfoCommentCell", forIndexPath: indexPath) as! PlaceInfoCommentCell
            let comment = place.placeInfo.comments[indexPath.row - PlaceInfoViewRows.Comments.rawValue - commentsRowDelta]
            cell.commentLabel.text = comment.text
            cell.timestampLabel.text = dateFormatter.stringFromDate(comment.timestamp)
            return cell
        }
        
        fatalError()
    }

    // MARK: - from MKMapViewDelegate:
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return MKTileOverlayRenderer(overlay: overlay)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if animated {
            mapView.centerCoordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = mapView.dequeueReusableAnnotationViewWithIdentifier("place") as? PlacePinView ??
            PlacePinView(annotation: annotation, reuseIdentifier: "place")
        pin.configure(place)
        pin.canShowCallout = false
        return pin
    }
    
}


