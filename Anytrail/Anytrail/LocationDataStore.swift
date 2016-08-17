//
//  LocationDataStore.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/17/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import CoreLocation

class LocationDataStore {
    
    static let sharedInstance = LocationDataStore()
    
    var origin: CLLocationCoordinate2D?
    var destination: CLLocationCoordinate2D?
    
    var originString: String?
    var destinationString: String?
}

extension LocationDataStore {
    
    func settingRectangleForFoursquare() -> ([Double]) {
        let north: Double
        let south: Double
        let east: Double
        let west: Double
        if let origin = origin{
            if let destination = destination {
        let originLatitude = origin.latitude
        let originLongitude = origin.longitude
        let endLatitude = destination.latitude
        let endLongitude = destination.longitude
        
        if originLatitude >= endLatitude {
            north = originLatitude
            south = endLatitude
        } else {
            north = endLatitude
            south = originLatitude
        }
        
        if originLongitude >= endLongitude {
            east = originLongitude
            west = endLongitude
        } else {
            east = endLongitude
            west = originLongitude
        }
        
        return [north, east, south, west]
            }
        }
        return[]
    }
}