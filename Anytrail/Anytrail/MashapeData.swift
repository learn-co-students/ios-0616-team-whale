//
//  MashapeData.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/9/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//


import Foundation
import SwiftyJSON
import UIKit

class MashapeData {
    var activityType : String
    var isHiking : Bool
    var placeLongitude : Double
    var placeLatitude : Double
    var placeName : String
    
    init(json: JSON){
        guard let
            activity = json["activities"]["activity_type_name"].string,
            name = json["name"].string,
            latitude = json["lat"].double,
            longitude = json["lon"].double
        else {
                fatalError("There was an error retrieving the information from Mashape")
        }
        
        
        if activity.containsString("hiking") || activity.containsString("hike") {
            isHiking = true
        } else {
            isHiking = false
        }
        activityType = activity
        placeLatitude = latitude
        placeLongitude = longitude
        placeName = name
            
    }
    
}