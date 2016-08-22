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
        case Path
        case Error

    }
    
    var type: ATAnnotationType
    
    init(typeSelected: ATAnnotationType) {
        self.type = typeSelected
    }
    
    
    var backgroundColor: UIColor {
        switch type {
        case .Origin:
            return ATConstants.Colors.BLUE
        case .Destination:
            return ATConstants.Colors.RED
        case .Waypoint:
            return ATConstants.Colors.GREEN
        case .PointOfInterest:
            return ATConstants.Colors.ORANGE
        case .Path:
            return ATConstants.Colors.PURPLE
        default:
            return ATConstants.Colors.GRAY
        }
    }
}