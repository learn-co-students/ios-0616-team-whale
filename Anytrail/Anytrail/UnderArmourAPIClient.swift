//
//  UnderArmourAPIClient.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/10/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON

class UnderArmourAPIClient {
    class func getHikingNearby(completion: (JSON?) -> ()){
        let clientKey = Keys.underArmourKey
        let clientSecret = Keys.underArmourSecret
        let clientAuth = Keys.underArmourAuthToken
        var currentLocation = "38.95,-77.35"
        var maximumDistance = "5000"
        var minimumDistance = "1"

        let parameters = ["Content-Type":"application/json",
                          "Api-Key":clientKey,
                          "Authorization":"Bearer + \(clientAuth)",
                          "close_to_location":currentLocation,
                          "maximum_distance":maximumDistance,
                          "minimum_distance":minimumDistance]
        
        let url = "https://oauth2-api.mapmyapi.com/v7.1/route/"
        let headers = ["Api-Key": clientKey,
                       "Authorization":"Bearer + \(clientAuth)",
                       "Content-Type": "application/json"]
        
        Alamofire.request(.GET, url, parameters: parameters, headers: headers).responseJSON { (response) in
            if let data = response.data {
                let jsonData = JSON(data : data)
                print(jsonData)
                    completion(jsonData)
            }
        }
    }
}

      