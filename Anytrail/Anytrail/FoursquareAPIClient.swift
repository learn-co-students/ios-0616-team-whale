//
//  FoursquareAPIClient.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class FoursquareAPIClient {
    class func getQueryForSearchLandmarks(completion: (JSON?) -> ()){
        let store = LocationDataStore.sharedInstance
        
        let coordinatesNESW:[Double] = store.settingRectangleForFoursquare()
        let sw = "\(coordinatesNESW[2]),\(coordinatesNESW[3])"
        let ne = "\(coordinatesNESW[0]),\(coordinatesNESW[1])"
        let clientID = Keys.fourSquareClientID
        let clientSecret = Keys.fourSquareClientSecret
        let v = "20160808"
        let ll = "40.7,-74"
        let query = "monuments/landmarks"
        let parameter = ["client_id": clientID,
                         "client_secret":clientSecret,
                         "v":v,
                         "ll": ll,
                         "query" : query,
                         "ne" : ne,
                         "sw": sw]
        
        
        Alamofire.request(.GET, "https://api.foursquare.com/v2/venues/explore", parameters: parameter, headers: nil).responseJSON { (response) in
            if let data = response.data {
                let jsonData = JSON(data : data)
                for venue in jsonData["response"]["groups"].array! {
                    for item in venue["items"] {
                        print(item.1.dictionary!["venue"]!["name"])
                    }
                }
                completion(jsonData)
            }
        }
    }
    
    
    class func getImagesForPlaces(completion: ([IDs]) -> ()
    

}
