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
    var placeVenue : [String : JSON]
    //    var placeName : String
    //    var placeLocation : [String : JSON]
    //
    
    
    init(json: JSON){
        
        guard let
            venue = json["venue"].dictionary
            //        name = json["name"].string,
            //        location = json["location"].dictionary
            else {
                fatalError("There was an error retrieving the information from FourSquare")
        }
        placeVenue = venue
        //        placeName = name
        //        placeLocation = location
        
        
    }
    
}