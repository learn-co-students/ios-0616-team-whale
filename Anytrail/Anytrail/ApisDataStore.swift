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
    
    
    func getDataWithCompletion(completion: () -> ()) {
        
        if let originLocation = LocationDataStore.sharedInstance.origin,
            destinationLocation = LocationDataStore.sharedInstance.destination {
            foursquareParameters = prepareForLandmarksQuery(originLocation, destinationLocation: destinationLocation)
        }
        
        FoursquareAPIClient.getQueryForSearchLandmarks(foursquareParameters) { itemsJSON in
            guard let itemsArray = itemsJSON else {
                print("error: no data recieved from API Client")
                return
            }
            
            self.foursquareData.removeAll()
            
            for venue in itemsArray {
                self.foursquareData.insert(FoursquareData(json: venue))
            }
            
            completion()
        }
    }
    
    func prepareForLandmarksQuery(originLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) -> [String: String] {
        
        let startLocation = CLLocation(latitude: originLocation.latitude, longitude: originLocation.longitude)
        let endLocation = CLLocation(latitude: destinationLocation.latitude, longitude: destinationLocation.longitude)
        let midPoint = startLocation.distanceFromLocation(endLocation) / 2
        let origin = "\(startLocation.coordinate.latitude), \(endLocation.coordinate.longitude)"
        let parameter = ["client_id": Keys.fourSquareClientID,
                         "client_secret": Keys.fourSquareClientSecret,
                         "v": FoursquareConstants.v,
                         "ll": origin,
                         "query": FoursquareConstants.query,
                         "radius": midPoint.description]
        
        return parameter
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



