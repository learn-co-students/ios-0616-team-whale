//
//  HealthKitConstants.swift
//  Anytrail
//
//  Created by Michael Amundsen on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import HealthKit

struct HealthKitDataTypes {
    static let healthKitDataSampleTypes = Array(HealthKitDataStore.sharedInstance.healthKitDataReadTypes)
    static let workouts = HKSampleType.workoutType()
    static let stepCount = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
    static let basalEnergyBurned = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)
    static let flightsClimbed = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
    static let walkingRunningDistance = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
    static let exerciseTime = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierAppleExerciseTime)
    static let activeEnergyBurned = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
    static let heartRate = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
    static let userHeight = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
    static let userWeight = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
    static let waterConsumption = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)
}