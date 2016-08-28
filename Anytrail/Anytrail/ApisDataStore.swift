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
                         "v": "20160826",
                         "intent": "browse",
                         "ll": "\(queryLocation.coordinate.latitude), \(queryLocation.coordinate.longitude)",
                         "radius": "\(LocationDataStore.sharedInstance.totalDistance() / 2.0)",
                         "categoryId": "\(ATConstants.Endpoints.monumentLandmarkID),\(ATConstants.Endpoints.trialID),\(ATConstants.Endpoints.waterfrontID),\(ATConstants.Endpoints.sculptureGardenID),\(ATConstants.Endpoints.scenicLookoutID),\(ATConstants.Endpoints.pedestrianPlaza),\(ATConstants.Endpoints.parkID),\(ATConstants.Endpoints.nationalParkID),\(ATConstants.Endpoints.gardenID),\(ATConstants.Endpoints.bridgeID),\(ATConstants.Endpoints.botanticalGardenID),\(ATConstants.Endpoints.breweryID),\(ATConstants.Endpoints.streetFairID),\(ATConstants.Endpoints.publicArtID),\(ATConstants.Endpoints.museumID),\(ATConstants.Endpoints.historicSiteID)"]
        
        return parameter
    }
    
    func getDataWithCompletion(queryLocation: CLLocation, completion: Bool -> ()) {
        let foursquareParameters = prepareForLandmarksQuery(queryLocation)
        
        FoursquareAPIClient.getQueryForSearchLandmarks(foursquareParameters) { itemsJSON in
            guard let itemsArray = itemsJSON.0?.dictionary!["venues"]?.array else {
                print("error: no data recieved from API Client")
                completion(false)
                return
            }
            
            for venue in itemsArray {
                self.foursquareData.insert(FoursquareData(json: venue))
            }
            completion(true)
        }
    }
    
    func pointOfInterestEpicenterQuery(completion: Bool -> ()) {
        guard let pointOfInterestEpicenters = LocationDataStore.sharedInstance.returningLongLatArray() else {
            completion(false)
            return
        }
        foursquareData.removeAll()
        let group = dispatch_group_create()
        for pointOfInterest in pointOfInterestEpicenters {
            dispatch_group_enter(group)
            getDataWithCompletion(CLLocation(latitude: pointOfInterest.latitude, longitude:  pointOfInterest.longitude)) {_ in dispatch_group_leave(group)}
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            completion(true)
            
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



