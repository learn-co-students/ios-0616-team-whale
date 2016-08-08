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
    var placeLongitude : Float
    var placeLatitude : Float
    var placeName : String
    //    var placeName : String
    //    var placeLocation : [String : JSON]
    //
//    func getVenue(json: JSON) -> JSON? {
//        var venueArray : JSON
//        for venue in json["response"]["groups"].array! {
//            venueArray = venue
//        }
//        return venueArray
//    }
//    
//    func getName(json: JSON) -> String?{
//        var name : String
//        let venue = getVenue(json)
//        for item in venue!["items"] {
//            name = (item.1.dictionary!["venue"]!["name"]).stringValue
//        }
//        return name
//    }
//    
//    func getLongitude(json: JSON) -> String?{
//        var longitude : String
//        let venue = getVenue(json)
//        for item in venue!["items"] {
//            longitude = (item.1.dictionary!["venue"]!["location"]["lng"]).stringValue
//        }
//        return longitude
//    }
//    
//    func getLatitude(json: JSON) -> String?{
//        var latitude : String
//        let venue = getVenue(json)
//        for item in venue!["items"] {
//            latitude = (item.1.dictionary!["venue"]!["location"]["lat"]).stringValue
//        }
//        return latitude
//    }
    
    init(json: JSON){
        guard let
            venue = json["venue"].dictionary,
            longitude = venue["location"]!["lng"].float,
            latitude = venue["location"]!["lat"].float,
            name = venue["name"]!.string
        
            //        name = json["name"].string,
            //        location = json["location"].dictionary
        
            else {
                fatalError("There was an error retrieving the information from FourSquare")
        }
        placeVenue = venue
        placeLatitude = (latitude)
        placeLongitude = (longitude)
        placeName = name
        //        placeName = name
        //        placeLocation = location
        
        
    }
    
}