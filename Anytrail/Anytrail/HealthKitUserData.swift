//
//  HealthKitUserData.swift
//
//
//  Created by Michael Amundsen on 8/16/16.
//
//

import Foundation

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
                if let sampleTypeName = sampleTypeName {
                    switch sampleTypeName {
                    case "HKQuantityTypeIdentifierStepCount":
                        print("Step Count")
                    case "HKQuantityTypeIdentifierAppleExerciseTime":
                        print("Exercise Time")
                    case "HKQuantityTypeIdentifierFlightsClimbed":
                        print("Flights Climbed")
                    case "HKQuantityTypeIdentifierDistanceWalkingRunning":
                        print("Distance")
                    case "HKQuantityTypeIdentifierActiveEnergyBurned":
                        print("Active Energy")
                    case "HKQuantityTypeIdentifierBasalEnergyBurned":
                        print("Resting Energy")
                    case "HKQuantityTypeIdentifierHeartRate":
                        print("Heart Rate")
                    default:
                        print(sampleTypeName)
                    }
                }
            })
        }
        
        
    }
}