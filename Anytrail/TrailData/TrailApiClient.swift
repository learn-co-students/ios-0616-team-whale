//
//  TrailApiClient.swift
//  Anytrail
//
//  Created by Sergey Nevzorov on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import Alamofire


protocol AllActivitiesProtocol {
    func generateData(category: String, completion: [InitActivities] -> Void)
}


class AllActivitiesClass: AllActivitiesProtocol {
    
    func generateData(category: String, completion: [InitActivities] -> Void) {
        
        let keyAndURL = "https://ridb.recreation.gov/api/v1/\(category)?apikey=\(Keys.trailClientID)"
        
        Alamofire.request(.GET, keyAndURL)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if let recData = JSON["RECDATA"] as? [AnyObject] {
                        print(recData.count)
                        var allActivities: [InitActivities] = []
                        
                        for item in recData {
                            
                            var name: String = ""
                            var numberOfActivities: String = ""
                            
                            if let unwrappedName = item["RecAreaName"] as? String {
                                name = unwrappedName
                            }
                            
                            if let unwrappedActivity = item["RecAreaDescription"] as? String {
                                numberOfActivities = unwrappedActivity
                            }
                            
                            allActivities.append(InitActivities(activityID: numberOfActivities, name: name))
                        }
                        completion(allActivities)
                    }
                }
        }
    }
}

struct InitActivities: CustomStringConvertible {
    let activityID: String?
    let name: String?
    
    var description: String {return "\(name ?? ""), \(activityID ?? "")" }
}


