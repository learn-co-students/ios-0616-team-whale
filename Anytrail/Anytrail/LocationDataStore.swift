//
//  LocationDataStore.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/17/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import CoreLocation
import MapKit

class LocationDataStore {
    
    static let sharedInstance = LocationDataStore()
    
    var origin: CLLocation?
    var destination: CLLocation?
    var originString: String?
    var destinationString: String?
    var longLatArray: [Double]?
    
}

extension LocationDataStore {
    
    func findDistance(origin: CLLocation, destination: CLLocation) -> Double {
        return origin.distanceFromLocation(destination)
    }
    
    func totalDistance() -> Double {
        guard let destination = destination, origin = origin else {
            return 0
        }
        return origin.distanceFromLocation(destination)
    }
    
    func pointOfInterestDistancePadding() -> Double? {
        guard let destination = destination, origin = origin else {
            return nil
        }
        return findDistance(origin, destination: destination) / 5
    }
    
    func midpointCoordinates(fromLocation: CLLocation, toLocation: CLLocation) -> CLLocationCoordinate2D {
        guard (fromLocation.coordinate.latitude, fromLocation.coordinate.longitude) != (toLocation.coordinate.latitude, toLocation.coordinate.latitude) else {
            return fromLocation.coordinate
        }
        return CLLocationCoordinate2D(latitude: (fromLocation.coordinate.latitude + toLocation.coordinate.latitude) / 2, longitude: (fromLocation.coordinate.longitude + toLocation.coordinate.longitude) / 2)
    }
    
    func returningLongLatArray() -> [CLLocationCoordinate2D]? {
        guard let destination = destination, origin = origin else {
            return nil
        }
        
//        var counter = 0.0
//        var earlierDestinations = [CLLocationCoordinate2D]()
//        var laterDestinations = [CLLocationCoordinate2D]()
//        let distance = findDistance(origin, destination: destination)
//        let paddingDistance = pointOfInterestDistancePadding() ?? 1.0
        let calculatedMidpoint = midpointCoordinates(origin, toLocation: destination)
        
//        var currentStartCenterMidpoint = CLLocation(latitude: calculatedMidpoint.latitude, longitude: calculatedMidpoint.longitude)
//        var currentCenterEndMidpoint = CLLocation(latitude: calculatedMidpoint.latitude, longitude: calculatedMidpoint.longitude)
//        
//        while counter < distance / (paddingDistance * 2) {
//            let startCenterMidpoint = midpointCoordinates(origin, toLocation: currentStartCenterMidpoint)
//            earlierDestinations.append(startCenterMidpoint)
//            let centerEndMidpoint = midpointCoordinates(currentCenterEndMidpoint, toLocation: destination)
//            laterDestinations.append(centerEndMidpoint)
//            currentStartCenterMidpoint = CLLocation(latitude: startCenterMidpoint.latitude, longitude: startCenterMidpoint.longitude)
//            currentCenterEndMidpoint = CLLocation(latitude: centerEndMidpoint.latitude, longitude: centerEndMidpoint.longitude)
//            counter += 1.0
//        }
//        earlierDestinations.appendContentsOf(laterDestinations)
//        earlierDestinations.append(calculatedMidpoint)
        return [calculatedMidpoint]
    }
}