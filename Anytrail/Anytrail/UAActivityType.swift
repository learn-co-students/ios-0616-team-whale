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
    var isLocationAware : Bool?
    
    init(idJson:JSON){
        
        guard let
            activityName = idJson["name"].string,
            isItLocationAware = idJson["location_aware"].bool
            else { print("this was an error reaching underArmour")
                return }
        
        let keyWordSearch = ["walking", "hiking", "run", "jog"]
        
        isLocationAware = isItLocationAware
        
        if isLocationAware != false {
            for keyWord in keyWordSearch {
                if activityName.containsString(keyWord) || activityName == keyWord {
                    if let selfDictionary = idJson["_links"]["self"][0].dictionary {
                        activityID = selfDictionary["id"]?.string
                        print(activityID)
                        print("******************************************")
                    
                    }
                }
            }
        }
    }
 }