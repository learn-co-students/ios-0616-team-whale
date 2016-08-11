//
//  UATrails.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/11/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class UATrails {
    
    
    var activityIDs : [String]?
    var isLocationAware : Bool = false
    
    init(idJson:JSON){
        guard let
            embeddedDictionary = idJson["_embedded"].dictionary
            else { print("this was an error reaching underArmour")
                return }
        
        guard let
            activityName = embeddedDictionary["name"]?.string,
            activityLinks = embeddedDictionary["_links"]?.array,
            isItLocationAware = embeddedDictionary["location_aware"]?.bool
            else { print("this was an error reaching underArmour")
                return }
        
        
        isLocationAware = isItLocationAware
        let keyWordSearch = ["walking", "hiking", "run", "jog"]
        var activityIdArrayInitial: [String] = []
        for keyWord in keyWordSearch {
            if isLocationAware{
                if activityName.containsString(keyWord) {
                    for activityLink in activityLinks {
                        if let activityLinkArray = activityLink.array{
                            if let activityDictionary = activityLinkArray[0].dictionary {
                                if let idNum = activityDictionary["id"]?.string {
                                    activityIdArrayInitial.append(idNum)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        activityIDs = activityIdArrayInitial
        
    }
}