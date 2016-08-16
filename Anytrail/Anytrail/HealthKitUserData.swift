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
    var todayHeartRate: Double?
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
    
    func getHeartRateForToday() {
        HealthKitDataStore.sharedInstance.healthKitStatisticQueryWithCompletionHandler(HealthKitDataTypes.heartRate!, startDate: yesterday!, endDate: today, statisticResultType: "average", HKUnitType: HKUnit.countUnit()) { healthKitStatisticData in
            return healthKitStatisticData.statisticValue
        }
    }
    
    func getWaterConsumptionToday() {
        HealthKitDataStore.sharedInstance.healthKitStatisticQueryWithCompletionHandler(HealthKitDataTypes.waterConsumption!, startDate: yesterday!, endDate: today, statisticResultType: "sum", HKUnitType: HKUnit.literUnit()) { healthKitStatisticData in
            return healthKitStatisticData.statisticValue
        }
    }
}


//    func getCurrentDaysHealthData() {
//
//        let calendar = NSCalendar.currentCalendar()
//        let today = NSDate()
//        let yesterday = calendar.dateByAddingUnit(.Day, value: -1, toDate: today, options: [])
//
//        guard let yesterdayDate = yesterday where yesterday != nil else {
//            print("There was an issue getting yesterday's date: \(yesterday)")
//            return
//        }
//
//        processHealthKitData(yesterdayDate, endDate: today)
//
//    }
//
//    func processHealthKitData(startDate: NSDate, endDate: NSDate) {
//        for sampleType in HealthKitDataTypes.healthKitDataSampleTypes {
//            HealthKitDataStore.sharedInstance.healthKitStatisticQueryWithCompletionHandler(sampleType, startDate: startDate, endDate: endDate, statisticResultType: "sum", HKUnitType: , completionHandler: <#T##healthKitStatisticData -> Void#>)
//        }
//
//
//    }
//
//    func getSampleType(sampleType: String?, healthKitSamples: [HKQuantitySample]) {
//        if let sampleTypeName = sampleType {
//            switch sampleTypeName {
//            case "HKQuantityTypeIdentifierStepCount":
//                HealthKitDataStore.sharedInstance.fetchTotalJoulesConsumedWithCompletionHandler({ (sum, error) in
//                    print(sum)
//                })
//            case "HKQuantityTypeIdentifierAppleExerciseTime":
//                let exceriseTime = healthKitSamples.reduce(0.0) {
//                    $0 + $1.quantity.doubleValueForUnit(HKUnit.minuteUnit())
//                }
//                print(exceriseTime)
//            case "HKQuantityTypeIdentifierFlightsClimbed":
//                let flightsClimbed = healthKitSamples.reduce(0.0) {
//                    $0 + $1.quantity.doubleValueForUnit(HKUnit.countUnit())
//                }
//                print(flightsClimbed)
//            case "HKQuantityTypeIdentifierDistanceWalkingRunning":
//                let distance = healthKitSamples.reduce(0.0) {
//                    $0 + $1.quantity.doubleValueForUnit(HKUnit.meterUnit())
//                }
//                print(distance)
//            case "HKQuantityTypeIdentifierActiveEnergyBurned":
//                let activeEnergy = healthKitSamples.reduce(0.0) {
//                    $0 + $1.quantity.doubleValueForUnit(HKUnit.calorieUnit())
//                }
//                print(activeEnergy)
//            case "HKQuantityTypeIdentifierBasalEnergyBurned":
//                let restingEnergy = healthKitSamples.reduce(0.0) {
//                    $0 + $1.quantity.doubleValueForUnit(HKUnit.calorieUnit())
//                }
//                print(restingEnergy)
//            case "HKQuantityTypeIdentifierHeartRate":
//                let heartRate = healthKitSamples.reduce(0.0) {
//                    $0 + $1.quantity.doubleValueForUnit(HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit()))
//                }
//                print((heartRate/Double(healthKitSamples.count)))
//            case "HKQuantityTypeIdentifierDietaryWater":
//                let water = healthKitSamples.reduce(0.0) {
//                    $0 + $1.quantity.doubleValueForUnit(HKUnit.literUnit())
//                }
//                print(water)
//            default:
//                print(sampleTypeName)
//            }
//        }
//    }
//}