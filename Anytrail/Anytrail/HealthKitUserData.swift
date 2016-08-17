//
//  HealthKitUserData.swift
//
//
//  Created by Michael Amundsen on 8/16/16.
//
//

import Foundation
import HealthKit

class HealthKitUserData {
    
    let userHealthData: [String]
    let today = NSDate()
    let yesterday = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: []) ?? NSDate()
    
    var todayStepCount: Double?
    var todayBasalEnergy: Double?
    var todayFlightClimbed: Double?
    var todayDistance: Double?
    var todayExercise: Double?
    var todayActiveEnergy: Double?
    var todayWaterCosumed: Double?
    
    
    init() {
        self.userHealthData = []
    }
    
    func getStepCountForToday(completion: (Double?) -> Void) {
        guard let stepCountType = HealthKitDataStoreSampleTypes.stepCount else {
            return
        }
        HealthKitDataStore.sharedInstance.sumOfData(stepCountType, fromDate: yesterday, toDate: today, statisticOptions: .CumulativeSum, unitType: HKUnit.countUnit()) { stepCountSum in
            completion(stepCountSum.value)
        }
    }
    
    func getBasalEnergyForToday(completion: (Double?) -> Void) {
        guard let basalEnergyType = HealthKitDataStoreSampleTypes.basalEnergyBurned else {
            return
        }
        HealthKitDataStore.sharedInstance.sumOfData(basalEnergyType, fromDate: yesterday, toDate: today, statisticOptions: .CumulativeSum, unitType: HKUnit.calorieUnit()) { basalEnergySum in
            completion(basalEnergySum.value)
        }
    }
    
    func getFlightCountForToday(completion: (Double?) -> Void) {
        guard let flightClimbedType = HealthKitDataStoreSampleTypes.flightsClimbed else {
            return
        }
        HealthKitDataStore.sharedInstance.sumOfData(flightClimbedType, fromDate: yesterday, toDate: today, statisticOptions: .CumulativeSum, unitType: HKUnit.countUnit()) { flightClimbedSum in
            completion(flightClimbedSum.value)
        }
    }
    
    func getDistanceForToday(completion: (Double?) -> Void) {
        guard let distanceWalkedType = HealthKitDataStoreSampleTypes.walkingRunningDistance else {
            return
        }
        HealthKitDataStore.sharedInstance.sumOfData(distanceWalkedType, fromDate: yesterday, toDate: today, statisticOptions: .CumulativeSum, unitType: HKUnit.mileUnit()) { distanceWalkedSum in
            completion(distanceWalkedSum.value)
        }
    }
    
    func getExerciseForToday(completion: (Double?) -> Void) {
        guard let exerciseTimeType = HealthKitDataStoreSampleTypes.exerciseTime else {
            return
        }
        HealthKitDataStore.sharedInstance.sumOfData(exerciseTimeType, fromDate: yesterday, toDate: today, statisticOptions: .CumulativeSum, unitType: HKUnit.minuteUnit()) { exerciseTimeSum in
            completion(exerciseTimeSum.value)
        }
    }
    
    func getActiveEnergyForToday(completion: (Double?) -> Void) {
        guard let activeEnergyType = HealthKitDataStoreSampleTypes.activeEnergyBurned else {
            return
        }
        HealthKitDataStore.sharedInstance.sumOfData(activeEnergyType, fromDate: yesterday, toDate: today, statisticOptions: .CumulativeSum, unitType: HKUnit.calorieUnit()) { activeEnergySum in
            completion(activeEnergySum.value)
        }
    }
    
    func getWaterConsumptionToday(completion: (Double?) -> Void) {
        guard let waterConsumedType = HealthKitDataStoreSampleTypes.waterConsumption else {
            return
        }
        HealthKitDataStore.sharedInstance.sumOfData(waterConsumedType, fromDate: yesterday, toDate: today, statisticOptions: .CumulativeSum, unitType: HKUnit.literUnit()) { waterConsumedSum in
            completion(waterConsumedSum.value)
        }
    }
}