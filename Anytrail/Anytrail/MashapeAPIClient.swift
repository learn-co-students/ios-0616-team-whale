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
        let url = "https://trailapi-trailapi.p.mashape.com"
        
        
        Alamofire.request(.GET, url, parameters: parameter, headers: nil).responseJSON { (response) in
            if let data = response.data {
                let jsonData = JSON(data : data)
                if let places = jsonData["places"].array{
                    for place in places {
                        if let activities = place["activities"].array {
                            for activity in activities {
                                print("##########\(activity["activity_type_name"].string)")
                            }
                            print(place)
                        }
                    }
                    
                }
                completion(jsonData)
            }
        }
    }
}

      