//
//  FoursquareDataStore.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

class ApisDataStore {
    
    static let sharedInstance = ApisDataStore()
    var foursquareData: Set<FoursquareData> = []
    var mashapeData: [MashapeData] = []
    var foursquareIDs: [String] = []
    var foursquareParameters: [String: String] = [:]
    
    func prepareForLandmarksQuery(queryLocation: CLLocation) -> [String: String] {
        let parameter = ["client_id": Keys.fourSquareClientID,
                         "client_secret": Keys.fourSquareClientSecret,
                         "v": FoursquareConstants.v,
                         "intent": "browse",
                         "ll": "\(queryLocation.coordinate.latitude), \(queryLocation.coordinate.longitude)",
                         "query": FoursquareConstants.query,
                         "radius": "\(LocationDataStore.sharedInstance.pointOfInterestDistancePadding() ?? 0)"]
        
        return parameter
    }
    
    func getDataWithCompletion(queryLocation: CLLocation, completion: () -> ()) {
        let foursquareParameters = prepareForLandmarksQuery(queryLocation)
        
        FoursquareAPIClient.getQueryForSearchLandmarks(foursquareParameters) { itemsJSON in
            guard let itemsArray = itemsJSON else {
                print("error: no data recieved from API Client")
                return
            }
            
            for venue in itemsArray {
                self.foursquareData.insert(FoursquareData(json: venue))
            }
            completion()
        }
    }
    
    func pointOfInterestEpicenterQuery(completion: () -> ()) {
        guard let pointOfInterestEpicenters = LocationDataStore.sharedInstance.returningLongLatArray() else {
            return
        }
        foursquareData.removeAll()
        let group = dispatch_group_create()
        for pointOfInterest in pointOfInterestEpicenters {
            dispatch_group_enter(group)
            getDataWithCompletion(CLLocation(latitude: pointOfInterest.latitude, longitude:  pointOfInterest.longitude)) {dispatch_group_leave(group)}
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            completion()
        }
    }
}

//    func getPhotoIDDataWithCompletion(completion: () -> ()) {
//        FoursquareAPIClient.getPhotoForVenue(<#T##venueIdentifier: String##String#>, completion: <#T##(UIImage?) -> ()#>)
//    }


//func getTrailsWithCompletion(completion: () -> ()) {
//    MashapeAPIClient.getTrails { (json) in
//        self.mashapeData.removeAll()
//        guard let json = json else { print("error: no data recieved from mashape API Client"); return}
//        for object in json {
//            if let trailData = object.1.array {
//                for i in 0..<trailData.count{
//                    self.mashapeData.append(MashapeData(json: trailData[i]))
//                    print("@@@@@@@@@@@@@@\(trailData[i])")
//                }
//            }
//        }
//        completion()
//    }
//}
//}



