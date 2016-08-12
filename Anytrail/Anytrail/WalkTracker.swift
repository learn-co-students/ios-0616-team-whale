//
//  WalkTracker.swift
//  Anytrail
//
//  Created by Michael Amundsen on 8/11/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import CoreMotion

class WalkTracker: NSObject {
    
    let pedometer = CMPedometer()
    var walkTimer = NSTimer()
    let walkStartDate: NSDate
    var walkEndDate: NSDate
    var currentWalkTime: Double
    var walkDistance: Double
    
    
    override init() {
        self.walkStartDate = NSDate()
        self.walkEndDate = NSDate()
        self.currentWalkTime = 0.0
        self.walkDistance = 0.0
    }
    
    
    func startWalk() {
        walkTimer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                           target: self,
                                                           selector: #selector(updateWalkDistanceAndTime(_:)),
                                                           userInfo: nil,
                                                           repeats: true)
    }
    
    func updateWalkDistance() {
        pedometer.startPedometerUpdatesFromDate(walkStartDate) { pedometerData, error in
            guard let pedometerData = pedometerData where error != nil else {
                self.walkTimer.invalidate()
                print("Please start your walk again: \(error)")
                return
            }
            
            let distanceWalked = pedometerData.distance
            
            if let distanceWalked = distanceWalked {
                self.walkDistance = Double(distanceWalked)
            }
        }
    }
    
    func updateWalkDistanceAndTime(timer: NSTimer) {
        currentWalkTime += 1
        updateWalkDistance()
    }
    
    func stopWalk() {
        walkEndDate = NSDate()
        pedometer.stopPedometerUpdates()
        walkTimer.invalidate()
    }
}
