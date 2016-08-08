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
    static let stepCountRead = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
    static let basalEnergyBurnedRead = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)
    static let flightsClimbedRead = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
    static let walkingRunningDistanceRead = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
    static let exerciseTimeRead = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierAppleExerciseTime)
    static let activeEnergyBurnedRead = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
    static let heartRateRead = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
    static let userHeightRead = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
    static let userWeightRead = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
    static let waterConsumptionRead = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)
    static let stepCountWrite = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
    static let flightsClimbedWrite = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
    static let walkingRunningDistanceWrite = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
    static let waterConsumptionWrite = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)
}