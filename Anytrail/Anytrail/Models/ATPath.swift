//
//  ATPath.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/18/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import CoreLocation

class ATPath {
    
    var coordinates: [CLLocationCoordinate2D]
    
    init(coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
    }
}