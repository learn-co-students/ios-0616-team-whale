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
        guard let distanceType = HealthKitDataTypes.walkingRunningDistance where HealthKitDataTypes.walkingRunningDistance != nil else {
            print("There is an issue with access healthkit walkingRunning type")
            return
        }
        HealthKitDataStore.sharedInstance.getSampleDataWithInDates(distanceType, startDate: startDate, endDate: endDate, limit: 0, ascendingValue: true) { distanceData in
            let distanceSamples = distanceData.dataSamples
            dispatch_async(dispatch_get_main_queue(),{
                self.walkDistance = distanceSamples.reduce(0.0) {
                    $0 + $1.quantity.doubleValueForUnit(HKUnit.meterUnit())
                }
            })
        }
    }
    
    func startWalk() {
        walkTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
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
        currentWalkTime = secondsBetweenDates(walkStartDate, endDate: NSDate())
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
