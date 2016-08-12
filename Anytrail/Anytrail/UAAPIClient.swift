//
//  UAAPIClient.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/10/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON

class UAAPIClient {
    let store = ApisDataStore.sharedInstance
    
    class func getHikingNearby(completion: ([UATrails]) -> ()){
        var trailsArray = [UATrails]()
        let clientKey = Keys.underArmourKey
        let clientSecret = Keys.underArmourSecret
        let clientAuth = Keys.underArmourAuthToken
        //MARK: TODO get current location for parameter.
        var currentLocation = "40.733683,-73.9911419"
        let maximumDistance = "200"
        let minimumDistance = "1"
        
        let parameters = ["Content-Type":"application/json",
                          "Api-Key":clientKey,
                          "Authorization": clientAuth,
                          "close_to_location":currentLocation,
                          "maximum_distance":maximumDistance,
                          "minimum_distance":minimumDistance]
        
        let url = "https://oauth2-api.mapmyapi.com/v7.1/route/"
        let headers = ["Api-Key": clientKey,
                       "Authorization": clientAuth]
        
        
        Alamofire.request(.GET, url, parameters: parameters, headers: headers).responseJSON { (response) in
            if let data = response.data {
                let jsonData = JSON(data:data)
                if let trailData = jsonData["_embedded"]["routes"].array {
                    for trail in trailData {
                        trailsArray.append((UATrails(json: trail)))
                    }
                }
            }
                completion(trailsArray)
        }
    }
    //send array of model
    class func getHikingOrWalkingIDs(completion: ([UAActivityType])->()){
        var activitiesArray = [UAActivityType]()
        let clientKey = Keys.underArmourKey
        let clientAuth = Keys.underArmourAuthToken
        let parameter = ["Api-Key":clientKey,
                         "Authorization": clientAuth]
        let header = ["Api-Key":clientKey,
                      "Authorization": clientAuth]
        let url = "https://oauth2-api.mapmyapi.com/v7.1/activity_type/"
        Alamofire.request(.GET, url, parameters: parameter, headers: header).responseJSON { (response) in
            if let data = response.data {
                let jsonData = JSON(data:data)
                if let activityTypesData = jsonData["_embedded"]["activity_types"].array {
                    
                    
                    for activity in activityTypesData{
                        let currentActivity = (UAActivityType(idJson: activity))
                        if currentActivity.doesQualify == true {
                            activitiesArray.append(currentActivity)
                        }
                    }
                }
                completion(activitiesArray)
            }
        }
    }
}

      