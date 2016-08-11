//
//  WalkTracker.swift
//  Anytrail
//
//  Created by Michael Amundsen on 8/11/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import HealthKit

class WalkTracker {
    
    let walkStartDate: NSDate
    var walkDistance = 0.0
    var currentWalkTime = 0.0
    
    init() {
        self.walkStartDate = NSDate()
    }
    
    func updateDistance(timer: NSTimer) {
        HealthKitDataStore.sharedInstance.getSampleDataWithInDates(HealthKitDataTypes.walkingRunningDistance!, startDate: walkStartDate, endDate: NSDate(), limit: 0, ascendingValue: true) { distanceHealthKitResponse in
            let distanceDataSamplesArray = distanceHealthKitResponse.dataSamples
            for distanceSample in distanceDataSamplesArray {
                self.walkDistance += distanceSample.quantity.doubleValueForUnit(HKUnit.mileUnit())
            }
        }
    }
}
