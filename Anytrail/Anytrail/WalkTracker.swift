//
//  WalkTracker.swift
//  Anytrail
//
//  Created by Michael Amundsen on 8/11/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import CoreMotion
import HealthKit

class WalkTracker: NSObject {
    
    var pedometer: CMPedometer
    var walkTimer: NSTimer
    var walkStartDate: NSDate
    var walkEndDate: NSDate
    var currentWalkTime: Double
    var walkDistance: Double
    
    override init() {
        self.pedometer = CMPedometer()
        self.walkTimer = NSTimer()
        self.walkStartDate = NSDate()
        self.walkEndDate = NSDate()
        currentWalkTime = 0.0
        walkDistance = 0.0
    }
    
    convenience init(startDate: NSDate, continueDate: NSDate) {
        self.init()
        self.walkStartDate = startDate
        self.walkEndDate = continueDate
        self.currentWalkTime = secondsBetweenDates(startDate, endDate: continueDate)
        getWalkDistance(startDate, endDate: continueDate)
    }
    
    func secondsBetweenDates(startDate: NSDate, endDate: NSDate) -> Double {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Second], fromDate: startDate, toDate: endDate, options: [])
        return Double(components.second)
    }
    
    func getWalkDistance(startDate: NSDate, endDate: NSDate) {
        HealthKitDataStore.sharedInstance.getSampleDataWithInDates(HealthKitDataTypes.walkingRunningDistance!, startDate: startDate, endDate: endDate, limit: 0, ascendingValue: true) { distanceData in
            let distanceSamples = distanceData.dataSamples
            for distanceSample in distanceSamples {
                let distanceValue = distanceSample.quantity.doubleValueForUnit(HKUnit.meterUnit())
                self.walkDistance += distanceValue
            }
        }
    }
    
    func startWalk() {
        walkTimer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                           target: self,
                                                           selector: #selector(updateWalkDistanceAndTime(_:)),
                                                           userInfo: nil,
                                                           repeats: true)
        AppDelegate.activeWorkout = true
    }
    
    func updateWalkDistance() {
        pedometer.startPedometerUpdatesFromDate(walkStartDate) { pedometerData, error in
            guard let pedometerData = pedometerData where error == nil else {
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
        AppDelegate.activeWorkout = false
        walkTimer.invalidate()
        HealthKitDataStore.sharedInstance.saveWalk(walkDistance, timeRecorded: currentWalkTime, startDate: walkStartDate, endDate: walkEndDate)
    }
}
