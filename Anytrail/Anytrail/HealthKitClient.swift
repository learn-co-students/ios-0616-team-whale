//
//  HealthKitClient.swift
//  Anytrail
//
//  Created by Michael Amundsen on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitClient {
    typealias authorizationResponse = (success: Bool?, error: NSError?)
    
    var healthKitDataReadTypes = Set<HKSampleType>()
    var healthKitDataWriteTypes = Set<HKSampleType>()
    
    func prepareHealthKitReadTypes() {
        
        let healthKitDataTypesOptionals = [HealthKitDataTypes.stepCount,
                                           HealthKitDataTypes.basalEnergyBurned,
                                           HealthKitDataTypes.flightsClimbed,
                                           HealthKitDataTypes.walkingRunningDistance,
                                           HealthKitDataTypes.exerciseTime,
                                           HealthKitDataTypes.activeEnergyBurned,
                                           HealthKitDataTypes.heartRate,
                                           HealthKitDataTypes.userHeight,
                                           HealthKitDataTypes.userWeight,
                                           HealthKitDataTypes.waterConsumption]
        
        for dataType in healthKitDataTypesOptionals {
            if let dataType = dataType {
                healthKitDataReadTypes.insert(dataType)
            }
        }
    }
    
    func prepareHealthKitTypesToWrite() {
        
        let healthKitDataTypes = [HealthKitDataTypes.stepCount,
                                  HealthKitDataTypes.flightsClimbed,
                                  HealthKitDataTypes.walkingRunningDistance,
                                  HealthKitDataTypes.waterConsumption]
        
        for dataType in healthKitDataTypes {
            if let dataType = dataType {
                healthKitDataWriteTypes.insert(dataType)
            }
        }
    }
    
    func authorizeHealthKit(completion: authorizationResponse -> Void) {
        prepareHealthKitReadTypes()
        prepareHealthKitTypesToWrite()
        
        HealthKitDataStore.healthKitStore.requestAuthorizationToShareTypes(healthKitDataWriteTypes, readTypes: healthKitDataReadTypes) { (success, error) in
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
