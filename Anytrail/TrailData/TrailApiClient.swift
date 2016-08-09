//
//  TrailApiClient.swift
//  Anytrail
//
//  Created by Sergey Nevzorov on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class TrailApiClient {
    class func getTrails(completion: (JSON?) -> ()){
        let clientID = Keys.trailClientID
        //let hikingId = 14
        let parameter = ["apikey" : clientID]
        let url = "https://ridb.recreation.gov/api/v1/"
        
        
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


//
//protocol AllActivitiesProtocol {
//    func generateData(category: String, completion: [InitActivities] -> Void)
//}
//
//
//class AllActivitiesClass: AllActivitiesProtocol {
//    
//    func generateData(category: String, completion: [InitActivities] -> Void) {
//        
//        let keyAndURL = "\(category)?apikey=\(Keys.trailClientID)"
//        
//        Alamofire.request(.GET, keyAndURL)
//            .responseJSON { response in
//                if let JSON = response.result.value {
//                    if let recData = JSON["RECDATA"] as? [AnyObject] {
//                        print(recData.count)
//                        var allActivities: [InitActivities] = []
//                        
//                        for item in recData {
//                            
//                            var name: String = ""
//                            var numberOfActivities: String = ""
//                            
//                            if let unwrappedName = item["RecAreaName"] as? String {
//                                name = unwrappedName
//                            }
//                            
//                            if let unwrappedActivity = item["RecAreaDescription"] as? String {
//                                numberOfActivities = unwrappedActivity
//                            }
//                            
//                            allActivities.append(InitActivities(activityID: numberOfActivities, name: name))
//                        }
//                        completion(allActivities)
//                    }
//                }
//        }
//    }
//}
//
//struct InitActivities: CustomStringConvertible {
//    let activityID: String?
//    let name: String?
//    
//    var description: String {return "\(name ?? ""), \(activityID ?? "")" }
//}
//

