//
//  UATrails.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/11/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class UATrails {
    
    var coordinatesOfTrail : [Double] = []
    var trailActivityType : String = ""
    init(json:JSON) {
        guard let
            longitude = json["starting_location"]["coordinates"][0].double,
            latitude = json["starting_location"]["coordinates"][1].double,
            trailActivityID = json["_links"]["activity_types"][0]["id"].string
            else { print("this was an error reaching underArmour trails portion")
                return }
      
        trailActivityType = trailActivityID
        let coordinates = [longitude, latitude]
        coordinatesOfTrail = coordinates

    }
}