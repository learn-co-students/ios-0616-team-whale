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
    var healthKitStore: HKHealthStore?
    var healthKitDataReadTypes = Set<HKSampleType>()
    
    struct StatisticData {
        var value: Double?
        var error: NSError?
    }
    
    init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        healthKitStore = HKHealthStore()
    }
    
    func sumOfData(type: HKQuantityType, fromDate: NSDate, toDate: NSDate, statisticOptions: HKStatisticsOptions, unitType: HKUnit, completion: StatisticData -> Void) {
        let dateRangePredicate = HKQuery.predicateForSamplesWithStartDate(fromDate, endDate: toDate, options: [])
        let query =  HKStatisticsQuery(quantityType: type, quantitySamplePredicate: dateRangePredicate, options: statisticOptions) { query, result, error in
            
            completion(StatisticData(value: result?.sumQuantity()?.doubleValueForUnit(unitType), error: error))
        }
        HealthKitDataStore.sharedInstance.healthKitStore?.executeQuery(query)
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
        
        healthKitStore?.requestAuthorizationToShareTypes(Set(arrayLiteral: HealthKitDataTypes.workouts), readTypes: HealthKitDataStore.sharedInstance.healthKitDataReadTypes) { (success, error) in
            if success {
                completion((success: true, error: nil))
            } else {
                completion((success: false, error: error))
            }
        }
    }
    
    func saveWalk(distanceRecorded: Double, timeRecorded: NSTimeInterval, startDate: NSDate, endDate: NSDate) {
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distanceRecorded)
        
        let workoutSession = HKWorkout(activityType: .Walking, startDate: startDate, endDate: endDate, duration: timeRecorded, totalEnergyBurned: nil, totalDistance: distanceQuantity, metadata: nil)
        
        healthKitStore?.saveObject(workoutSession, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                print(error)
            } else {
                print("The distance has been recorded! Better go check!")
            }
        })
    }
}
