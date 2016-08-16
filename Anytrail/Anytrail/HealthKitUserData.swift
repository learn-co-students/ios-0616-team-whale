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
    
    init() {
        self.userHealthData = []
    }
    
    func getCurrentDaysHealthData() {
        
        let calendar = NSCalendar.currentCalendar()
        let today = NSDate()
        let yesterday = calendar.dateByAddingUnit(.Day, value: -1, toDate: today, options: [])
        
        guard let yesterdayDate = yesterday where yesterday != nil else {
            print("There was an issue getting yesterday's date: \(yesterday)")
            return
        }
        
        processHealthKitData(yesterdayDate, endDate: today)
        
    }
    
    func processHealthKitData(startDate: NSDate, endDate: NSDate) {
        for sampleType in HealthKitDataTypes.healthKitDataSampleTypes {
            HealthKitDataStore.sharedInstance.getSampleDataWithInDates(sampleType, startDate: startDate, endDate: endDate, limit: 0, ascendingValue: true, completion: { healthKitSamplesData in
                let sampleTypeName = healthKitSamplesData.dataSamples.first?.quantityType.description
                let healthKitSamples = healthKitSamplesData.dataSamples
                self.getSampleType(sampleTypeName, healthKitSamples: healthKitSamples)
            })
        }
        
        
    }
    
    func getSampleType(sampleType: String?, healthKitSamples: [HKQuantitySample]) {
        if let sampleTypeName = sampleType {
            switch sampleTypeName {
            case "HKQuantityTypeIdentifierStepCount":
                HealthKitDataStore.sharedInstance.fetchTotalJoulesConsumedWithCompletionHandler({ (sum, error) in
                    print(sum)
                })
            case "HKQuantityTypeIdentifierAppleExerciseTime":
                let exceriseTime = healthKitSamples.reduce(0.0) {
                    $0 + $1.quantity.doubleValueForUnit(HKUnit.minuteUnit())
                }
                print(exceriseTime)
            case "HKQuantityTypeIdentifierFlightsClimbed":
                let flightsClimbed = healthKitSamples.reduce(0.0) {
                    $0 + $1.quantity.doubleValueForUnit(HKUnit.countUnit())
                }
                print(flightsClimbed)
            case "HKQuantityTypeIdentifierDistanceWalkingRunning":
                let distance = healthKitSamples.reduce(0.0) {
                    $0 + $1.quantity.doubleValueForUnit(HKUnit.meterUnit())
                }
                print(distance)
            case "HKQuantityTypeIdentifierActiveEnergyBurned":
                let activeEnergy = healthKitSamples.reduce(0.0) {
                    $0 + $1.quantity.doubleValueForUnit(HKUnit.calorieUnit())
                }
                print(activeEnergy)
            case "HKQuantityTypeIdentifierBasalEnergyBurned":
                let restingEnergy = healthKitSamples.reduce(0.0) {
                    $0 + $1.quantity.doubleValueForUnit(HKUnit.calorieUnit())
                }
                print(restingEnergy)
            case "HKQuantityTypeIdentifierHeartRate":
                let heartRate = healthKitSamples.reduce(0.0) {
                    $0 + $1.quantity.doubleValueForUnit(HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit()))
                }
                print((heartRate/Double(healthKitSamples.count)))
            case "HKQuantityTypeIdentifierDietaryWater":
                let water = healthKitSamples.reduce(0.0) {
                    $0 + $1.quantity.doubleValueForUnit(HKUnit.literUnit())
                }
                print(water)
            default:
                print(sampleTypeName)
            }
        }
    }
}