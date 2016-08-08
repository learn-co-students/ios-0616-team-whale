//
//  HealthKitDataStore.swift
//  Anytrail
//
//  Created by Michael Amundsen on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitDataStore {
    
    typealias authorizationResponse = (success: Bool?, error: NSError?)
    
    let healthKitStore = HKHealthStore()
    var healthKitDataTypesToRead = Set<HKObjectType>()
    var healthKitDataTypesToWrite = Set<HKSampleType>()
    
    func prepareHealthKitTypesToRead() {
        
        let healthKitDataTypes = [HealthKitDataTypes.stepCountRead,
                                  HealthKitDataTypes.basalEnergyBurnedRead,
                                  HealthKitDataTypes.flightsClimbedRead,
                                  HealthKitDataTypes.walkingRunningDistanceRead,
                                  HealthKitDataTypes.exerciseTimeRead,
                                  HealthKitDataTypes.activeEnergyBurnedRead,
                                  HealthKitDataTypes.heartRateRead,
                                  HealthKitDataTypes.userHeightRead,
                                  HealthKitDataTypes.userWeightRead,
                                  HealthKitDataTypes.waterConsumptionRead]
        
        for dataType in healthKitDataTypes {
            if let dataType = dataType {
                healthKitDataTypesToRead.insert(dataType)
            }
        }
    }
    
    func prepareHealthKitTypesToWrite() {
        
        let healthKitDataTypes = [HealthKitDataTypes.stepCountWrite,
                                  HealthKitDataTypes.flightsClimbedWrite,
                                  HealthKitDataTypes.walkingRunningDistanceWrite,
                                  HealthKitDataTypes.waterConsumptionWrite]
        
        for dataType in healthKitDataTypes {
            if let dataType = dataType {
                healthKitDataTypesToWrite.insert(dataType)
            }
        }
    }
    
    
    func authorizeHealthKit(completion: authorizationResponse -> Void) {
        
        healthKitStore.requestAuthorizationToShareTypes(healthKitDataTypesToWrite, readTypes: healthKitDataTypesToRead) { (success, error) in
            if success {
                completion((success: true, error: nil))
            } else {
                completion((success: false, error: nil))
            }
            
            if let error = error {
                completion((success: nil, error: error))
            }
        }
    }
}
