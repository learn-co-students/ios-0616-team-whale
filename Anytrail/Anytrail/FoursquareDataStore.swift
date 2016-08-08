//
//  FoursquareDataStore.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class FoursquareDataStore {
    
    static let sharedInstance = FoursquareDataStore()
    
    private init() {}
    
    
    var data:[FoursquareData] = []
    func getDataWithCompletion(completion: () -> ()) {
        FoursquareAPIClient.getQueryForSearchLandmarks { (json) in
            self.data.removeAll()
            guard let json = json else { print("error: no data recieved from API Client"); return}
            for object in json {
                let dataFS = object.1
                
                self.data.append(FoursquareData(json: dataFS))
            }
            completion()
            
        }
    }
    
}

