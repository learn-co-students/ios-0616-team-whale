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
    
    var origin: CLLocationCoordinate2D?
    var destination: CLLocationCoordinate2D?
    var originString: String?
    var destinationString: String?
    var longLatArray: [Double]?
    
}

extension LocationDataStore {
    
    func findDistance(origin:CLLocationCoordinate2D, destination: CLLocationCoordinate2D) -> (Double) {
        var getLat: CLLocationDegrees = origin.latitude
        var getLon: CLLocationDegrees = origin.longitude
        
        
        let origin: CLLocation =  CLLocation(latitude: getLat, longitude: getLon)
        
        getLat = destination.latitude
        getLon = destination.longitude
        
        let destination = CLLocation(latitude: getLat, longitude: getLon)
        return origin.distanceFromLocation(destination) //distance in meters
    }
    
    func determineRadius() -> Double {
        var distance: Double!
        
        if let destinationLoc = self.origin {
            if let originLoc = self.destination {
                distance = self.findDistance(originLoc, destination: destinationLoc)
            }
        }
        return distance/5
    }
    
    func midpointFormula(pointOne: CLLocationCoordinate2D, pointTwo: CLLocationCoordinate2D) -> (CLLocationCoordinate2D){
        //(x1+x2/2,y1+y2/2) latitudes = xs longs = ys
        let pointOneLongDouble = Double(pointOne.longitude)
        let pointOneLatDouble = Double(pointOne.latitude)
        let pointTwoLongDouble = Double(pointTwo.longitude)
        let pointTwoLatDouble = Double(pointTwo.latitude)
        switch ((pointOneLongDouble,pointOneLatDouble) == (pointTwoLongDouble,pointTwoLatDouble)) {
        case true:
            return CLLocationCoordinate2D.init(latitude: pointOneLatDouble, longitude: pointOneLongDouble)
        case false:
            var mid : CLLocationCoordinate2D = pointOne
            mid.latitude = (pointOneLatDouble + pointTwoLatDouble)/2
            mid.longitude = (pointOneLongDouble + pointTwoLongDouble)/2
            
            
            return mid
        }
        
    }
    func returningLongLatArray() -> [CLLocationCoordinate2D] {
        var counter = 0.0
        var earlierDestinations : [CLLocationCoordinate2D] = []
        var laterDestinations : [CLLocationCoordinate2D] = []
        var distance: Double!
        let radius = self.determineRadius()
        
        if let destinationLoc = self.origin {
            if let originLoc = self.destination {
                distance = self.findDistance(originLoc, destination: destinationLoc)
                print("DISTANCE!!!!!!!!!! \(distance)")
            }
        }
        if let originalOrigin = origin {
            if let originalDestination = destination {
                let currentMidpoint = self.midpointFormula(originalOrigin, pointTwo: originalDestination)
                var currentEndMid : CLLocationCoordinate2D = currentMidpoint
                var currentStartMid : CLLocationCoordinate2D! = currentMidpoint
                while counter < distance / (radius*2) {
                    let endMidpoints = self.midpointFormula(currentEndMid, pointTwo: originalDestination)
                    laterDestinations.append(endMidpoints)
                    let startMidpoints = self.midpointFormula(originalOrigin, pointTwo: currentStartMid)
                    earlierDestinations.append(startMidpoints)
                    
                    currentEndMid = endMidpoints
                    currentStartMid = startMidpoints
                    print(distance%(radius*2))
                    counter += 1.0
                }
            }
        }
        earlierDestinations.appendContentsOf(laterDestinations)
        print("!@#%^$%&%^$*^*(&*)&*%^&#$%^@#$%!$!!!!!!!!!!!!!!\(earlierDestinations.count)")
        return earlierDestinations
    }
}