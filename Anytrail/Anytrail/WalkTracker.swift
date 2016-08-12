//
//  WalkTracker.swift
//  Anytrail
//
//  Created by Michael Amundsen on 8/11/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import HealthKit
import CoreMotion

class WalkTracker: NSObject {
    
    let walkStartDate = NSDate()
    var timer = NSTimer()
    let pedometer = CMPedometer()
    var currentWalkTime = 0.0
    
    var walkDistance: Double {
        return updateDistance()
    }
    
    
    
    func startWalk() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                            target: self,
                                                            selector: #selector(updateDistanceAndWalkTime(_:)),
                                                            userInfo: nil,
                                                            repeats: true)
    }
    
    
    func updateDistanceAndWalkTime(timer: NSTimer) {
        currentWalkTime += 1
        print(walkDistance)
        print(currentWalkTime)
    }
    
    func updateDistance() -> Double {
        var returnDistance = 0.0
        pedometer.startPedometerUpdatesFromDate(walkStartDate) { (pedometerData, error) in
            let distance = Double((pedometerData?.distance ?? 0))
            returnDistance += distance
        }
        return returnDistance
    }
}
