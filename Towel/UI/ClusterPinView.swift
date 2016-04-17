//
//  ClusterPinView.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 17..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import MapKit

class ClusterPinView: MKAnnotationView {
    
    weak var _countLabel: UILabel?
    
    private var _count: UInt = 1
    var count: UInt {
        get {
            return _count
        }
        set {
            _count = newValue
            _countLabel?.text = "\(_count)"
            _countLabel?.frame = CGRect(x: 12, y: 12, width: 20, height: 20)
            
            self.setNeedsDisplay()
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clearColor()
        frame = CGRectMake(center.x - 22,
                           center.y - 22,
                           44,
                           44);
        
        let countLabel = UILabel(frame: frame)
        countLabel.backgroundColor = UIColor.clearColor()
        countLabel.textColor = UIColor.whiteColor()
        countLabel.textAlignment = .Center
        countLabel.shadowColor = UIColor(white: 0.0, alpha:0.75)
        countLabel.shadowOffset = CGSizeMake(0, -1)
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.numberOfLines = 1
        countLabel.font = UIFont.boldSystemFontOfSize(12)
        countLabel.baselineAdjustment = .AlignCenters
        _countLabel = countLabel
        self.addSubview(countLabel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetAllowsAntialiasing(context, true)
        
        let outerCircleStrokeColor = UIColor(white: 0, alpha:0.25)
        let innerCircleStrokeColor = UIColor.whiteColor()
        let innerCircleFillColor = UIColor(red: (255.0 / 255.0), green: (95 / 255.0), blue: (42 / 255.0), alpha:1.0)
        
        let circleFrame = CGRectInset(rect, 4, 4);
        
        outerCircleStrokeColor.setStroke()
        CGContextSetLineWidth(context, 5.0)
        CGContextStrokeEllipseInRect(context, circleFrame)
        
        innerCircleStrokeColor.setStroke()
        CGContextSetLineWidth(context, 4)
        CGContextStrokeEllipseInRect(context, circleFrame)
        
        innerCircleFillColor.setFill()
        CGContextFillEllipseInRect(context, circleFrame)
    }
    
}
