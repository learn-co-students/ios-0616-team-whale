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
    
    var midpoint: CLLocationCoordinate2D
    
    var originString: String?
    var destinationString: String?
    
    var longLatArray: [Double]?
}

extension LocationDataStore {
    
    
    func midpointFormula(pointOne: CLLocationCoordinate2D, pointTwo: CLLocationCoordinate2D) -> [(Double,Double)]{
        var midArrayLower = []
        //(x1+x2/2,y1+y2/2) latitudes = xs longs = ys
        let pointOneLongDouble = Double(pointOne.longitude)
        let pointOneLatDouble = Double(pointOne.latitude)
        let pointTwoLongDouble = Double(pointTwo.longitude)
        let pointTwoLatDouble = Double(pointTwo.latitude)
        switch ((pointOneLongDouble,pointOneLatDouble) == (pointTwoLongDouble,pointTwoLatDouble)) {
        case true:
            return ([(pointOneLongDouble,pointOneLatDouble)])
        case false:
        let midLatitude = (pointOneLatDouble + pointTwoLatDouble)/2
        let midLongitude = (pointOneLongDouble + pointTwoLongDouble)/2
        
        let midpoint : (Double,Double)
            midpoint = (midLatitude,midLongitude)
        switch  {
        case <#pattern#>:
            <#code#>
        default:
            <#code#>
        }
        
        return midpoint
        }
        
    }
    func returningLongLatArray() -> ([CLLocationCoordinate2D],[CLLocationCoordinate2D]){
        var counter = 0
        var earlierDestinations : [CLLocationCoordinate2D] = []
        var laterDestinations : [CLLocationCoordinate2D] = []
        while counter < 3 {
            
        }
        
        
        
    }
    
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