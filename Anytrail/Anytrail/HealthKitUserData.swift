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
    let yesterday = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: [])
    
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
    
    func getStepCountForToday() {
        HealthKitDataStore.sharedInstance.healthKitStatisticQueryWithCompletionHandler(HealthKitDataTypes.stepCount!, startDate: yesterday!, endDate: today, statisticResultType: "sum", HKUnitType: HKUnit.countUnit()) { healthKitStatisticData in
            self.todayStepCount = healthKitStatisticData.statisticValue
        }
    }
    
    func getBasalEnergyForToday() {
        HealthKitDataStore.sharedInstance.healthKitStatisticQueryWithCompletionHandler(HealthKitDataTypes.basalEnergyBurned!, startDate: yesterday!, endDate: today, statisticResultType: "sum", HKUnitType: HKUnit.calorieUnit()) { healthKitStatisticData in
            self.todayBasalEnergy = healthKitStatisticData.statisticValue
        }
    }
    
    func getFlightCountForToday() {
        HealthKitDataStore.sharedInstance.healthKitStatisticQueryWithCompletionHandler(HealthKitDataTypes.flightsClimbed!, startDate: yesterday!, endDate: today, statisticResultType: "sum", HKUnitType: HKUnit.countUnit()) { healthKitStatisticData in
            self.todayFlightClimbed = healthKitStatisticData.statisticValue
        }
    }
    
    func getDistanceForToday() {
        HealthKitDataStore.sharedInstance.healthKitStatisticQueryWithCompletionHandler(HealthKitDataTypes.walkingRunningDistance!, startDate: yesterday!, endDate: today, statisticResultType: "sum", HKUnitType: HKUnit.meterUnit()) { healthKitStatisticData in
            self.todayDistance = healthKitStatisticData.statisticValue
        }
    }
    
    func getExerciseForToday() {
        HealthKitDataStore.sharedInstance.healthKitStatisticQueryWithCompletionHandler(HealthKitDataTypes.exerciseTime!, startDate: yesterday!, endDate: today, statisticResultType: "sum", HKUnitType: HKUnit.minuteUnit()) { healthKitStatisticData in
            self.todayExercise = healthKitStatisticData.statisticValue
        }
    }
    
    func getActiveEnergyForToday() {
        HealthKitDataStore.sharedInstance.healthKitStatisticQueryWithCompletionHandler(HealthKitDataTypes.activeEnergyBurned!, startDate: yesterday!, endDate: today, statisticResultType: "sum", HKUnitType: HKUnit.calorieUnit()) { healthKitStatisticData in
            self.todayActiveEnergy = healthKitStatisticData.statisticValue
        }
    }
    
    func getWaterConsumptionToday() {
        HealthKitDataStore.sharedInstance.healthKitStatisticQueryWithCompletionHandler(HealthKitDataTypes.waterConsumption!, startDate: yesterday!, endDate: today, statisticResultType: "sum", HKUnitType: HKUnit.literUnit()) { healthKitStatisticData in
            self.todayWaterCosumed = healthKitStatisticData.statisticValue
        }
    }
}