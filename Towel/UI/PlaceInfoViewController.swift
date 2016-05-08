//
//  PlaceInfoViewController.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 09..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import UIKit

class PlaceInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var place: Place!
    
    let dateFormatter: NSDateFormatter
    
    required init?(coder aDecoder: NSCoder) {
        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    // MARK: - from UITableViewDataSource:
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 +
            (place.placeInfo.descriptions.count > 0 ? 1 : 0) +
            (place.placeInfo.comments.count > 0 ? place.placeInfo.comments.count + 1 : 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            // title
            let cell = tableView.dequeueReusableCellWithIdentifier("placeInfoTitleCell", forIndexPath: indexPath) as! PlaceInfoTitleCell
            cell.titleLabel.text = titleFromLocation(place.placeInfo.location)
            return cell
        }
        
        if (indexPath.row == 1) {
            // stats
            let cell = tableView.dequeueReusableCellWithIdentifier("placeInfoStatsCell", forIndexPath: indexPath) as! PlaceInfoStatsCell
            cell.ratingLabel.text = place.avgRating != nil ? Rating.fromValue(place.avgRating!).toString() : "N/A"
            cell.waitingLabel.text = place.avgWaiting?.toString() ?? "N/A"
            return cell
        }
        
        let hasDescription = place.placeInfo.descriptions.count > 0
        let commentsRow = hasDescription ? 3 : 2
        
        if (indexPath.row == 2 && hasDescription) {
            // description
            let cell = tableView.dequeueReusableCellWithIdentifier("placeInfoDescriptionCell", forIndexPath: indexPath) as! PlaceInfoDescriptionCell
            cell.descriptionLabel.text = place.placeInfo.descriptions.first!.text
            cell.descriptionLabel.sizeToFit()
            return cell
        }
        
        if (indexPath.row == commentsRow) {
            // comments subtitle
            let cell = tableView.dequeueReusableCellWithIdentifier("placeInfoCommentsTitleCell", forIndexPath: indexPath) as! PlaceInfoCommentsTitleCell
            return cell
        }
        
        if (indexPath.row > commentsRow) {
            // comments
            let cell = tableView.dequeueReusableCellWithIdentifier("placeInfoCommentCell", forIndexPath: indexPath) as! PlaceInfoCommentCell
            let comment = place.placeInfo.comments[indexPath.row - commentsRow - 1]
            cell.commentLabel.text = comment.text
            cell.timestampLabel.text = dateFormatter.stringFromDate(comment.timestamp)
            return cell
        }
        
        fatalError()
    }
    
}


