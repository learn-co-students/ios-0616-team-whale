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
    static let healthKitStore = HKHealthStore()
    
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
        healthKitStore.executeQuery(sampleQuery)
    }
}
