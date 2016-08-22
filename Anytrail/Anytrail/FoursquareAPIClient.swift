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
import CoreLocation

struct FoursquareConstants {
    static let v = "20160808"
    static let query = "HISTORIC/MONUMENTS/LANDMARKS/STATUES/MUSEUM/POI/Hiking trails"
}


class FoursquareAPIClient {
    
    class func getQueryForSearchLandmarks(parameter: [String: String], completion: [JSON]? -> ()) {
        
        Alamofire.request(.GET, ATConstants.Endpoints.FOURSQUARE_GET_VENUES, parameters: parameter, headers: nil).responseJSON { response in
            guard let data = response.data, responseJSON = JSON(data: data).dictionary?["response"], groupsJSON =  responseJSON["groups"].array, itemsJSON = groupsJSON[0]["items"].array else {
                completion(nil)
                return
            }
            completion(itemsJSON)
        }
    }
}

//
//        class func getPhotoForVenue(completion: (String?) -> ()) {
//            let clientID = Keys.fourSquareClientID
//            let clientSecret = Keys.fourSquareClientSecret
//
//            let v = "20160808"
//            let parameter = ["client_id"     : clientID,
//                             "client_secret" :clientSecret,
//                             "v"             : v,
//                             "VENUE_ID"      : id]
//
//
//
//
//            Alamofire.request(.GET, ATConstants.Endpoints.FOURSQUARE_GET_PHOTO, parameters: parameter, headers: nil).responseJSON { (response) in
//                if let data = response.data {
//                    let jsonData = JSON(data: data)
//                    //                for venue in jsonData["response"]["groups"].array! {
//                    //                    for item in venue["items"] {
//                    //                        print(item.1.dictionary!["venue"]!["id"])
//                    //                        print(item.1.dictionary!["venue"]!["name"])
//                    //                    }
//                    //                }
//
//                    //                completion(jsonData)
//                }
//            }
//        }
//    }
//}
