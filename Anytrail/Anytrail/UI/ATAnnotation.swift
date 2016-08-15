//
//  ATAnnotation.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/15/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Mapbox

class ATAnnotation: MGLPointAnnotation {
    
    enum ATAnnotationType: Int {
        case Origin
        case PointOfInterest
        case Waypoint
        case Destination
    }
    
    var type: ATAnnotationType?
    
    var backgroundColor: UIColor {
        if type == .Origin {
            return ATConstants.Colors.BLUE
            
        } else if type == .PointOfInterest {
            return ATConstants.Colors.ORANGE
            
        } else if type == .Waypoint {
            return ATConstants.Colors.GREEN
            
        } else {
            return ATConstants.Colors.RED
        }
    }
}