//
//  UnderArmourIDData.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/10/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class UnderArmourIDData {
    
    
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
        if isLocationAware {
            for keyWord in keyWordSearch {
                if activityName.containsString(keyWord) {
                    for activityLink in activityLinks {
                        guard let activityLinkArray = activityLink.array,
                            activityDictionary = activityLinkArray[0].dictionary,
                            idNum = activityDictionary["id"]?.string
                            else {
                                print("There was an error while accessing activity links")
                                return }
                        activityIdArrayInitial.append(idNum)
                    }
                }
            }
        }
        activityIDs = activityIdArrayInitial
    }
}