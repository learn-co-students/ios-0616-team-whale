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
    
    var isHiking : Bool?
    var placeLongitude : Double
    var placeLatitude : Double
    var placeName : String
    
    init(json: JSON){
        guard let
            activities = json["activities"].array,
            name = json["name"].string,
            latitude = json["lat"].double,
            longitude = json["lon"].double
        else {
                fatalError("There was an error retrieving the information from Mashape")
        }
        
        for activity in activities {
            if activity["activity_type_name"].string!.containsString("hiking"){
                isHiking = true
                print("***********\(activity) \(name) **************")
            } else {
                isHiking = false
            }
        }
        
        placeLatitude = latitude
        placeLongitude = longitude
        placeName = name
            
    }
    
}