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
    
    typealias healthKitSamplesData = (dataSamples: [HKQuantitySample], error: NSError?)
    typealias authorizationResponse = (success: Bool?, error: NSError?)
    
    static let sharedInstance = HealthKitDataStore()
    
    let healthKitStore = HKHealthStore()
    var healthKitDataReadTypes = Set<HKSampleType>()
    
    class func getSampleDataWithInDates(sampleType:HKSampleType, startDate: NSDate, endDate: NSDate, limit: Int, ascendingValue: Bool, completion: healthKitSamplesData -> Void) {
        let dateRangePredicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: ascendingValue)
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: dateRangePredicate, limit: limit, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error ) -> Void in
            
            guard let results = results where error == nil else {
                print(error)
                completion((dataSamples: [], error: error))
                return
            }
            
            let samplesArray = results as? [HKQuantitySample]
            
            if let samplesArray = samplesArray {
                completion((dataSamples: samplesArray, error: nil))
            }
        }
        sharedInstance.healthKitStore.executeQuery(sampleQuery)
    }
    
    func prepareHealthKitReadTypes() {
        let healthKitDataTypesOptionals: [HKSampleType?] = [HealthKitDataTypes.stepCount,
                                                            HealthKitDataTypes.walkingRunningDistance,
                                                            HealthKitDataTypes.flightsClimbed,
                                                            HealthKitDataTypes.activeEnergyBurned,
                                                            HealthKitDataTypes.exerciseTime,
                                                            HealthKitDataTypes.heartRate,
                                                            HealthKitDataTypes.basalEnergyBurned,
                                                            HealthKitDataTypes.workouts,
                                                            HealthKitDataTypes.waterConsumption]
        
        for dataType in healthKitDataTypesOptionals {
            if let dataType = dataType {
                HealthKitDataStore.sharedInstance.healthKitDataReadTypes.insert(dataType)
            }
        }
    }
    
    func authorizeHealthKit(completion: authorizationResponse -> Void) {
        prepareHealthKitReadTypes()
        
        healthKitStore.requestAuthorizationToShareTypes(Set(arrayLiteral: HealthKitDataTypes.workouts), readTypes: HealthKitDataStore.sharedInstance.healthKitDataReadTypes) { (success, error) in
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
