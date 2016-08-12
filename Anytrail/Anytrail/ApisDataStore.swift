//
//  ApisDataStore.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import SwiftyJSON

class ApisDataStore {
    //
    
    static let sharedInstance = ApisDataStore()
    var mashapeDataArray:[MashapeData] = []
    var foursquareDataArray:[FoursquareData] = []
    var UAActivityIdDataArray:[String] = []
    var UALocationDataArray:[UATrails] = []
    
    private init() {}
    
    
    func getFSDataWithCompletion(completion: () -> ()) {
        FoursquareAPIClient.getQueryForSearchLandmarks { (json) in
            self.foursquareDataArray.removeAll()
            guard let json = json else { print("error: no data recieved from API Client"); return}
            for object in json {
                if let dataFS = object.1["groups"][0]["items"].array {
                    
                    for i in 0..<dataFS.count {
                        self.foursquareDataArray.append(FoursquareData(json: dataFS[i]))
                    }
                    
                }
                
            }
            completion()
            
        }
        
    }
    
    func getMashapeTrailsWithCompletion(completion: () -> ()) {
        
        
        
        MashapeAPIClient.getTrails { (json) in
            self.mashapeDataArray.removeAll()
            guard let json = json else { print("error: no data recieved from mashape API Client"); return}
            for object in json {
                if let trailData = object.1.array {
                    for i in 0..<trailData.count{
                        self.mashapeDataArray.append(MashapeData(json: trailData[i]))
                    }
                    
                }
                
            }
            completion()
            
        }
        
        
    }
    
    
    
    func getUATrailsWithCompletion(completion: () -> ()) {
        
        UnderArmourAPIClient.getHikingNearby { (trailArray) in
            for trail in trailArray{
                self.UALocationDataArray.append(trail)
            }
            completion()
            
            
            
            
            
        }
        
        
        func getUAActivityIdDataWithCompletion(completion: () -> ()) {
            
            UnderArmourAPIClient.getHikingOrWalkingIDs { (activityArray) in
                for activity in activityArray{
                    if activity.doesQualify{
                        if let activityID = activity.activityID{
                            self.UAActivityIdDataArray.append(activityID)
                            
                        }
                    }
                }
                completion()
                
            }
        }
    }
}

