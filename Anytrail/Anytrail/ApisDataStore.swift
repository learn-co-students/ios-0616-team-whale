//
//  FoursquareDataStore.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import SwiftyJSON

class ApisDataStore {
    
    static let sharedInstance = ApisDataStore()
    
    private init() {
        //
    }
    
    var foursquareData: [FoursquareData] = []
    var mashapeData: [MashapeData] = []
    var foursquareIDs: [String] = []

    
    func getDataWithCompletion(completion: () -> ()) {
        FoursquareAPIClient.getQueryForSearchLandmarks { (json) in
            self.foursquareData.removeAll()
            guard let json = json else { print("error: no data recieved from API Client"); return }
            
            for object in json {
                if let dataFS = object.1["groups"][0]["items"].array {
                    
                    for i in 0..<dataFS.count {
                        self.foursquareData.append(FoursquareData(json: dataFS[i]))
                    }
                }
            }
            completion()
        }
    }
    
//    func getPhotoIDDataWithCompletion(completion: () -> ()) {
//        FoursquareAPIClient.getPhotoForVenue(<#T##venueIdentifier: String##String#>, completion: <#T##(UIImage?) -> ()#>)
//    }
    
    
    func getTrailsWithCompletion(completion: () -> ()) {
        MashapeAPIClient.getTrails { (json) in
            self.mashapeData.removeAll()
            guard let json = json else { print("error: no data recieved from mashape API Client"); return}
            for object in json {
                if let trailData = object.1.array {
                    for i in 0..<trailData.count{
                        self.mashapeData.append(MashapeData(json: trailData[i]))
                        print("@@@@@@@@@@@@@@\(trailData[i])")
                    }
                }
            }
            completion()
        }
    }
}



