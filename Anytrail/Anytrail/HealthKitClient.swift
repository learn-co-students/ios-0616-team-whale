//
//  HealthKitClient.swift
//  Anytrail
//
//  Created by Michael Amundsen on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import HealthKit
import WatchConnectivity
import DeviceKit

class HealthKitClient {
    typealias authorizationResponse = (success: Bool?, error: NSError?)
    typealias hardwareTypeAvailable = (phoneType: String, appleWatch: Bool)
    
    var healthKitDataReadTypes = Set<HKSampleType>()
    
    func checkAvaliableHardware() -> hardwareTypeAvailable {
        let deviceType = Device().description
        let appleWatchAvailable = WCSession.isSupported()
        return hardwareTypeAvailable(phoneType: deviceType, appleWatch: appleWatchAvailable)
    }
    
    func prepareHealthKitReadTypes(hardwareType: hardwareTypeAvailable) {
        
        switch hardwareType {
        case ("iPhone 5s", false), ("iPhone SE", false):
            let healthKitDataTypesOptionals = [HealthKitDataTypes.stepCount,
                                               HealthKitDataTypes.walkingRunningDistance,
                                               HealthKitDataTypes.waterConsumption]

        case ("iPhone 6", false), ("iPhone 6s", false):
            let healthKitDataTypesOptionals = [HealthKitDataTypes.stepCount,
                                               HealthKitDataTypes.walkingRunningDistance,
                                               HealthKitDataTypes.flightsClimbed,
                                               HealthKitDataTypes.waterConsumption]
        default:
            let healthKitDataTypesOptionals = [HealthKitDataTypes.stepCount,
                                               HealthKitDataTypes.basalEnergyBurned,
                                               HealthKitDataTypes.walkingRunningDistance,
                                               HealthKitDataTypes.exerciseTime,
                                               HealthKitDataTypes.activeEnergyBurned,
                                               HealthKitDataTypes.heartRate,
                                               HealthKitDataTypes.waterConsumption]
        }
        
        let healthKitDataTypesOptionals = [HealthKitDataTypes.stepCount,
                                           HealthKitDataTypes.basalEnergyBurned,
                                           HealthKitDataTypes.walkingRunningDistance,
                                           HealthKitDataTypes.exerciseTime,
                                           HealthKitDataTypes.activeEnergyBurned,
                                           HealthKitDataTypes.heartRate,
                                           HealthKitDataTypes.waterConsumption]
        
        for dataType in healthKitDataTypesOptionals {
            if let dataType = dataType {
                healthKitDataReadTypes.insert(dataType)
            }
        }
    }
    
    func authorizeHealthKit(completion: authorizationResponse -> Void) {
        prepareHealthKitReadTypes()
        
        HealthKitDataStore.healthKitStore.requestAuthorizationToShareTypes(Set(arrayLiteral: HealthKitDataTypes.workouts), readTypes: healthKitDataReadTypes) { (success, error) in
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
    
    //    func healthKitSearchQuery() {
    //
    //        let dataArray = Array(healthKitDataTypesTo)
    ////        let sampleType =
    ////            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
    //
    //        let query = HKObserverQuery(sampleType: HealthKitDataTypes.stepCount, predicate: nil) {
    //            query, completionHandler, error in
    //
    //            if error != nil {
    //
    //                // Perform Proper Error Handling Here...
    //                println("*** An error occured while setting up the stepCount observer. \(error.localizedDescription) ***")
    //                abort()
    //            }
    //
    //            // Take whatever steps are necessary to update your app's data and UI
    //            // This may involve executing other queries
    //            self.updateDailyStepCount()
    //
    //            // If you have subscribed for background updates you must call the completion handler here.
    //            // completionHandler()
    //        }
    //
    //        healthStore.executeQuery(query)
    //    }
}
