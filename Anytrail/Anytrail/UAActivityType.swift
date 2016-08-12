 //
 //UAActivityType.swift
 //  Anytrail
 //
 //  Created by Elli Scharlin on 8/10/16.
 //  Copyright © 2016 Flatiron School. All rights reserved.
 //
 
 import Foundation
 import SwiftyJSON
 import UIKit
 
 class UAActivityType {
    
    
    var activityID : String?
    var doesQualify : Bool = false
    var activityTypeName : String?
    
    init(idJson:JSON){
        
        
        
        guard let
            activityName = idJson["name"].string,
            isItLocationAware = idJson["location_aware"].bool,
            selfDictionary = idJson["_links"]["self"][0].dictionary,
            currentActivityID = selfDictionary["id"]!.string
            else { print("this was an error reaching underArmour")
                return }
        let keywords = ["Walk","Hik","Jog","Run"]
        
        activityTypeName = activityName
        activityID = currentActivityID
        if isItLocationAware {
            for keyword in keywords {
                if ((activityTypeName!.containsString(keyword))) {
                    doesQualify = true
                }
            }
        }
    }
 }