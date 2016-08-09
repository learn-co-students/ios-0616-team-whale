//
//  MashapeAPIClient.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/9/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//


import Foundation
import Alamofire
import SwiftyJSON

class MashapeAPIClient {
    class func getTrails(completion: (JSON?) -> ()){
        let clientID = Keys.mashapeKey
        let parameter = ["mashape-key" : clientID]
        
        Alamofire.request(.GET, "https://trailapi-trailapi.p.mashape.com", parameters: parameter, headers: nil).responseJSON { (response) in
            if let data = response.data {
                let jsonData = JSON(data : data)
//                for venue in jsonData["response"]["groups"].array! {
//                    for item in venue["items"] {
//                        print(item.1.dictionary!["venue"]!["name"])
//                    }
//                }
                completion(jsonData)
            }
        }
    }
    
    
}
