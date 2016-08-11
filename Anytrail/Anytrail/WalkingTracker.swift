//
//  WalkingTracker.swift
//  Anytrail
//
//  Created by Michael Amundsen on 8/10/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import CoreLocation
import HealthKit
import Mapbox

class WalkingTracker: NSObject {
    
    @IBOutlet var mapView: MGLMapView!
    
    var seconds = 0.0
    var distance = 0.0
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .Fitness
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    
    override init() {
        super.init()
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    func eachSecond(timer: NSTimer) {
        seconds += 1
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        print("Time: " + secondsQuantity.description)
        
        let distanceQuantity = HKQuantity(unit: HKUnit.mileUnit(), doubleValue: distance)
        print("Distance: " + distanceQuantity.description)
        
        let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.mileUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: seconds / distance)
        print("Pace: " + paceQuantity.description)
    }
    
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    
    func startWalk() {
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                       target: self,
                                                       selector: #selector(WalkingTracker.eachSecond(_:)),
                                                       userInfo: nil,
                                                       repeats: true)
        startLocationUpdates()

    }
    
}

// MARK: - CLLocationManagerDelegate
extension WalkingTracker: CLLocationManagerDelegate {
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                }
                
                //save location
                self.locations.append(location)
            }
        }
        
    }
    
}