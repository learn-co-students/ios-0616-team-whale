//
//  FoursquareData.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class FoursquareData {
    var placeVenue : [String: JSON]
    var placeLongitude : Double
    var placeLatitude : Double
    var placeName : String
    var placeAddress : String
    
    init(json: JSON){
        guard let
            venue = json["venue"].dictionary,
            longitude = venue["location"]!["lng"].double,
            latitude = venue["location"]!["lat"].double,
            address = venue["location"]!["formattedAddress"].array,
//            address = venue["location"]!["formattedAddress"].string,
            name = venue["name"]!.string
            //        name = json["name"].string,
            //        location = json["location"].dictionary
        
            else {
                fatalError("There was an error retrieving the information from FourSquare")
        }
        var addressStringConverter = ""
        for i in 0..<address.count {
          addressStringConverter.appendContentsOf(address[i].stringValue)
        }
        placeVenue = venue
        placeLatitude = (latitude)
        placeLongitude = (longitude)
        placeName = name
        placeAddress = addressStringConverter
        //        placeName = name
        //        placeLocation = location
        
        
    }
    
}