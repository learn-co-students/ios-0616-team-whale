//
//  HealthKitDataStore.swift
//  Anytrail
//
//  Created by Michael Amundsen on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import HealthKit

struct HealthKitDataStoreSampleTypes {
    static let workouts = HKWorkoutType.workoutType()
    static let stepCount = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
    static let basalEnergyBurned = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)
    static let flightsClimbed = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
    static let walkingRunningDistance = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
    static let exerciseTime = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierAppleExerciseTime)
    static let activeEnergyBurned = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
    static let heartRate = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
    static let userHeight = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
    static let userWeight = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
    static let waterConsumption = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)
}

struct StatisticData {
    var value: Double?
    var error: NSError?
}

struct SampleData {
    var value: [HKQuantitySample]?
    var error: NSError?
}

class HealthKitDataStore {
    private typealias SampleType = HealthKitDataStoreSampleTypes
    static let sharedInstance = HealthKitDataStore()
    var healthKitStore: HKHealthStore?
    var healthKitDataReadTypes = Set<HKSampleType>()
    var healthKitUserData: [(String, String)] = []
    
    init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        healthKitStore = HKHealthStore()
    }
    
    func prepareHealthKitReadTypes() {
        let healthKitDataTypesOptionals: [HKSampleType?] = [SampleType.stepCount,
                                                            SampleType.walkingRunningDistance,
                                                            SampleType.flightsClimbed,
                                                            SampleType.activeEnergyBurned,
                                                            SampleType.exerciseTime,
                                                            SampleType.heartRate,
                                                            SampleType.basalEnergyBurned,
                                                            SampleType.workouts,
                                                            SampleType.waterConsumption]
        
        for dataType in healthKitDataTypesOptionals {
            if let dataType = dataType {
                HealthKitDataStore.sharedInstance.healthKitDataReadTypes.insert(dataType)
            }
        }
    }
    
    func authorizeHealthKit(completion: NSError? -> Void) {
        prepareHealthKitReadTypes()
        healthKitStore?.requestAuthorizationToShareTypes(Set(arrayLiteral: SampleType.workouts), readTypes: HealthKitDataStore.sharedInstance.healthKitDataReadTypes) { _, error in
            completion(error)
        }
    }
    
    func sumOfData(type: HKQuantityType, fromDate: NSDate, toDate: NSDate, statisticOptions: HKStatisticsOptions, unitType: HKUnit, completion: StatisticData -> Void) {
        let dateRangePredicate = HKQuery.predicateForSamplesWithStartDate(fromDate, endDate: toDate, options: [])
        let query =  HKStatisticsQuery(quantityType: type, quantitySamplePredicate: dateRangePredicate, options: statisticOptions) { query, result, error in
            completion(StatisticData(value: result?.sumQuantity()?.doubleValueForUnit(unitType), error: error))
        }
        HealthKitDataStore.sharedInstance.healthKitStore?.executeQuery(query)
    }
    
    func getSamplesData(type:HKSampleType, fromDate: NSDate, toDate: NSDate, limit: Int, ascendingValue: Bool, completion: SampleData -> Void) {
        let dateRangePredicate = HKQuery.predicateForSamplesWithStartDate(fromDate, endDate: toDate, options: .None)
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: ascendingValue)
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: dateRangePredicate, limit: limit, sortDescriptors: [sortDescriptor]) { _, results, error in
            completion(SampleData(value: results as? [HKQuantitySample], error: error))
        }
        HealthKitDataStore.sharedInstance.healthKitStore?.executeQuery(sampleQuery)
    }
    
    func saveWalk(distanceRecorded: Double, timeRecorded: NSTimeInterval, startDate: NSDate, endDate: NSDate, completion: (Bool, NSError?) -> Void) {
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distanceRecorded)
        let workoutSession = HKWorkout(activityType: .Walking, startDate: startDate, endDate: endDate, duration: timeRecorded, totalEnergyBurned: nil, totalDistance: distanceQuantity, metadata: nil)
        healthKitStore?.saveObject(workoutSession) { success, error in
            completion(success, error)
        }
    }
    
    func getUserTodayHealthKitData(completion: () ->()) {
        let user = HealthKitUserData()
        
        user.getDistanceForToday { distanceSum in
            if let distanceSum = distanceSum {
                let distance = round(distanceSum * 100) / 100
                self.healthKitUserData.append((distance.description, "distance"))
            }
            completion()
        }
        
        user.getExerciseForToday { exerciseTimeSum in
            if let exerciseTimeSum = exerciseTimeSum {
                self.healthKitUserData.append((exerciseTimeSum.description, "exercise-time"))
            }
            completion()
        }
        
        user.getFlightCountForToday { flightClimbedSum in
            if let flightClimbedSum = flightClimbedSum {
                self.healthKitUserData.append((flightClimbedSum.description, "flight"))
            }
            completion()
        }
        
        user.getStepCountForToday { stepCountSum in
            if let stepCountSum = stepCountSum {
                self.healthKitUserData.append((stepCountSum.description, "steps"))
            }
            completion()
        }
        
        user.getActiveEnergyForToday { activeEnergySum in
            if let activeEnergySum = activeEnergySum {
                self.healthKitUserData.append((activeEnergySum.description, "energy-burn"))
            }
            completion()
        }
        user.getBasalEnergyForToday { basalEnergySum in
            if let basalEnergySum = basalEnergySum {
                self.healthKitUserData.append((basalEnergySum.description, "resting-burn"))
            }
            completion()
        }
        
        user.getWaterConsumptionToday { waterConsumptionSum in
            if let waterConsumptionSum = waterConsumptionSum {
                let waterConsumed = round(waterConsumptionSum * 10) / 10
                self.healthKitUserData.append((waterConsumed.description, "water"))
            }
            completion()
        }
    }
}
