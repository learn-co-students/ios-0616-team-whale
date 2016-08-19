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
    
    static let sharedInstance = WalkTracker()
    
    let pedometer = CMPedometer()
    lazy var walkTimer = NSTimer()
    var walkStartDate = NSDate()
    var walkEndDate: NSDate?
    var currentWalkTime = 0.0
    var walkDistance = 0.0
    var pace = 0.0
    var activeWalk: Bool?
    
    func continueSession(startDate: NSDate, continueDate: NSDate) {
        walkStartDate = startDate
        currentWalkTime = secondsBetweenDates(startDate, endDate: continueDate)
        getWalkDistance(startDate, endDate: continueDate)
        walkTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(updateWalkDistanceAndTime(_:)), userInfo: nil, repeats: true)
    }
    
    func resetWalk() {
        currentWalkTime = 0.0
        walkDistance = 0.0
        pace = 0.0
    }
    
    func secondsBetweenDates(startDate: NSDate, endDate: NSDate) -> Double {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Second], fromDate: startDate, toDate: endDate, options: [])
        return Double(components.second)
    }
    
    func getWalkDistance(startDate: NSDate, endDate: NSDate) {
        guard let distanceType = HealthKitDataStoreSampleTypes.walkingRunningDistance where HealthKitDataStoreSampleTypes.walkingRunningDistance != nil else {
            print("There is an issue with access healthkit walkingRunning type")
            return
        }
        HealthKitDataStore.sharedInstance.getSamplesData(distanceType, fromDate: startDate, toDate: endDate, limit: 0, ascendingValue: true) { distanceData in
            if let distanceSamples = distanceData.value {
                self.walkDistance = distanceSamples.reduce(0.0) {
                    $0 + $1.quantity.doubleValueForUnit(HKUnit.meterUnit())
                }
            }
        }
    }
    
    func startWalk() {
        walkTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(updateWalkDistanceAndTime(_:)), userInfo: nil, repeats: true)
        walkStartDate = NSDate()
        activeWalk = true
    }
    
    func updateWalkDistance() {
        pedometer.startPedometerUpdatesFromDate(walkStartDate) { pedometerData, error in
            guard let pedometerData = pedometerData where error == nil else {
                self.walkTimer.invalidate()
                print("Please start your walk again: \(error)")
                return
            }
            let distanceWalked = pedometerData.distance
            let currentPace = pedometerData.currentPace
            if let currentPace = currentPace {
                self.pace = currentPace.doubleValue
            }
            
            if let distanceWalked = distanceWalked {
                self.walkDistance = Double(distanceWalked)
            }
        }
    }
    
    func updateWalkDistanceAndTime(timer: NSTimer) {
        currentWalkTime = secondsBetweenDates(walkStartDate, endDate: NSDate())
        updateWalkDistance()
    }
    
    func stopWalk(completion: Bool -> Void) {
        walkEndDate = NSDate()
        pedometer.stopPedometerUpdates()
        activeWalk = false
        walkTimer.invalidate()
        
        if let walkEndDate = walkEndDate {
            HealthKitDataStore.sharedInstance.saveWalk(walkDistance, timeRecorded: currentWalkTime, startDate: walkStartDate, endDate: walkEndDate) { saveResult, error in
                completion(saveResult)
            }
        }
        resetWalk()
    }
}
