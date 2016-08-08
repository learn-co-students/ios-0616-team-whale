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
    
    typealias authorizationResponse = (success: Bool, error: NSError?)
    
    let healthKitStore = HKHealthStore()
    var healthKitDataTypesToRead = Set<HKObjectType>()
    var healthKitDataTypesToWrite = Set<HKSampleType>()
    
    
    func prepareHealthKitTypesToRead() {
        
        let stepCount = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let basalEnergyBurned = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)
        let flightsClimbed = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
        let walkingRunningDistance = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
        let exerciseTime = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierAppleExerciseTime)
        let activeEnergyBurned = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
        let heartRate = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        let userHeight = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        let userWeight = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        let waterConsumption = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)
        
        let healthKitDataTypes = [stepCount, basalEnergyBurned, flightsClimbed, walkingRunningDistance, exerciseTime, activeEnergyBurned, heartRate, userHeight, userWeight, waterConsumption]
        
        for dataType in healthKitDataTypes {
            if let dataType = dataType {
                healthKitDataTypesToRead.insert(dataType)
            }
        }
    }
    
    func prepareHealthKitTypesToWrite() {
        
        let stepCount = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let basalEnergyBurned = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)
        let flightsClimbed = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
        let walkingRunningDistance = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
        let exerciseTime = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierAppleExerciseTime)
        let activeEnergyBurned = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
        let heartRate = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        let userHeight = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        let userWeight = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        let waterConsumption = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)
        
        let healthKitDataTypes = [stepCount, basalEnergyBurned, flightsClimbed, walkingRunningDistance, exerciseTime, activeEnergyBurned, heartRate, userHeight, userWeight, waterConsumption]
        
        for dataType in healthKitDataTypes {
            if let dataType = dataType {
                healthKitDataTypesToWrite.insert(dataType)
            }
        }
    }
    
    
    func authorizeHealthKit(completion: authorizationResponse -> Void) {
        
    }
}
