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
    
    static let sharedInstance = FoursquareAPIClient()
    
    class func getQueryForSearchLandmarks(completion: (JSON?) -> ()){
        let store = LocationDataStore.sharedInstance
        
        //        let coordinatesNESW:[Double] = store.settingRectangleForFoursquare()
        //        let sw = "\(coordinatesNESW[2]),\(coordinatesNESW[3])"
        //        let ne = "\(coordinatesNESW[0]),\(coordinatesNESW[1])"
       
        
        let clientID = Keys.fourSquareClientID
        let clientSecret = Keys.fourSquareClientSecret
//        NSOperationQueue().addOperationWithBlock {
        for latLong in store.returningLongLatArray(){
            let origin = "\(Double(latLong.latitude)), \(Double(latLong.longitude))"
            
            let v = "20160808"
            let query = "HISTORIC/MONUMENTS/LANDMARKS/STATUES/MUSEUM"
            let parameter = ["client_id": clientID,
                             "client_secret":clientSecret,
                             "v":v,
                             "ll": origin,
                             "query" : query,
                             "radius" : String(store.determineRadius())]
            //                         "ne" : ne,
            //                         "sw": sw]
//            print(parameter)
            Alamofire.request(.GET, ATConstants.Endpoints.FOURSQUARE_GET_VENUES, parameters: parameter, headers: nil).responseJSON { (response) in
                if let data = response.data {
                    let jsonData = JSON(data: data)
                    //                for venue in jsonData["response"]["groups"].array! {
                    //                    for item in venue["items"] {
                    //                        print(item.1.dictionary!["venue"]!["id"])
                    //                        print(item.1.dictionary!["venue"]!["name"])
                    //                    }
                    //                }
                   
                 completion(jsonData)
                }
            }
        }
    }
    

    
        class func getPhotoForVenue(completion: (String?) -> ()) {
            let clientID = Keys.fourSquareClientID
            let clientSecret = Keys.fourSquareClientSecret
            
            let v = "20160808"
            let parameter = ["client_id"     : clientID,
                             "client_secret" :clientSecret,
                             "v"             : v,
                             "VENUE_ID"      : id]
            
            

            
            Alamofire.request(.GET, ATConstants.Endpoints.FOURSQUARE_GET_PHOTO, parameters: parameter, headers: nil).responseJSON { (response) in
                if let data = response.data {
                    let jsonData = JSON(data: data)
                    //                for venue in jsonData["response"]["groups"].array! {
                    //                    for item in venue["items"] {
                    //                        print(item.1.dictionary!["venue"]!["id"])
                    //                        print(item.1.dictionary!["venue"]!["name"])
                    //                    }
                    //                }
                    
                    //                completion(jsonData)
                }
            }
        }
    }
}
