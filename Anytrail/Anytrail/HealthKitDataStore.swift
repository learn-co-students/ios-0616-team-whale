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
    
    let stepCount = HKQuantityTypeIdentifierStepCount
    let basalEnergyBurned = HKQuantityTypeIdentifierBasalEnergyBurned
    let flightsClimbed = HKQuantityTypeIdentifierFlightsClimbed
    let walkingRunningDistance = HKQuantityTypeIdentifierDistanceWalkingRunning
    let exerciseTime = HKQuantityTypeIdentifierAppleExerciseTime
    let activeEnergyBurned = HKQuantityTypeIdentifierActiveEnergyBurned
    let heartRate = HKQuantityTypeIdentifierHeartRate
    let userHeight = HKQuantityTypeIdentifierHeight
    let userWeight = HKQuantityTypeIdentifierBodyMass
    let waterConsumption = HKQuantityTypeIdentifierDietaryWater
    
    
    func prepareHealthKitTypesToRead() {
        
        let stepCount1 = HKObjectType.quantityTypeForIdentifier(stepCount)
        let basalEnergyBurned1 = HKObjectType.quantityTypeForIdentifier(basalEnergyBurned)
        let flightsClimbed1 = HKObjectType.quantityTypeForIdentifier(flightsClimbed)
        let walkingRunningDistance1 = HKObjectType.quantityTypeForIdentifier(walkingRunningDistance)
        let exerciseTime1 = HKObjectType.quantityTypeForIdentifier(exerciseTime)
        let activeEnergyBurned1 = HKObjectType.quantityTypeForIdentifier(activeEnergyBurned)
        let heartRate1 = HKObjectType.quantityTypeForIdentifier(heartRate)
        let userHeight1 = HKObjectType.quantityTypeForIdentifier(userHeight)
        let userWeight1 = HKObjectType.quantityTypeForIdentifier(userWeight)
        let waterConsumption1 = HKObjectType.quantityTypeForIdentifier(waterConsumption)
        
        let healthKitDataTypes = [stepCount1, basalEnergyBurned1, flightsClimbed1, walkingRunningDistance1, exerciseTime1, activeEnergyBurned1, heartRate1, userHeight1, userWeight1, waterConsumption1]
        
        for dataType in healthKitDataTypes {
            if let dataType = dataType {
                healthKitDataTypesToRead.insert(dataType)
            }
        }
    }
    
    func prepareHealthKitTypesToWrite() {
        
        let stepCount1 = HKSampleType.quantityTypeForIdentifier(stepCount)
        let basalEnergyBurned1 = HKSampleType.quantityTypeForIdentifier(basalEnergyBurned)
        let flightsClimbed1 = HKSampleType.quantityTypeForIdentifier(flightsClimbed)
        let walkingRunningDistance1 = HKSampleType.quantityTypeForIdentifier(walkingRunningDistance)
        let activeEnergyBurned1 = HKSampleType.quantityTypeForIdentifier(activeEnergyBurned)
        let heartRate1 = HKSampleType.quantityTypeForIdentifier(heartRate)
        let userHeight1 = HKSampleType.quantityTypeForIdentifier(userHeight)
        let userWeight1 = HKSampleType.quantityTypeForIdentifier(userWeight)
        let waterConsumption1 = HKSampleType.quantityTypeForIdentifier(waterConsumption)
        
        let healthKitDataTypes = [stepCount1, basalEnergyBurned1, flightsClimbed1, walkingRunningDistance1, activeEnergyBurned1, heartRate1, userHeight1, userWeight1, waterConsumption1]
        
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
