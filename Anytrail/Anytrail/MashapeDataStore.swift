//
//  MashapeDataStore.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/9/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import SwiftyJSON

class MashapeDataStore {
    
    static let sharedInstance = MashapeDataStore()
    
    private init() {}
    
    
    var data:[MashapeData] = []
    func getDataWithCompletion(completion: () -> ()) {
        MashapeAPIClient.getTrails { (json) in
            self.data.removeAll()
            guard let json = json else { print("error: no data recieved from API Client"); return}
            for object in json {
                let trailData = object.1
                self.data.append(MashapeData(json: trailData))
                
                    
                    
                    //                    print(FoursquareData(json: dataFS))
                }
            }
            completion()
            
        }
    }
    
}
