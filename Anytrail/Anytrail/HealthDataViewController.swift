//
//  HealthDataViewController.swift
//  Anytrail
//
//  Created by Michael Amundsen on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import HealthKit

class HealthDataViewController: UIViewController {
    
    let healthKitDataStore = HealthKitDataStore.sharedInstance
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        healthKitDataStore.authorizeHealthKit { (response) in
        }
        
        getHealthData()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getHealthData() {
        
        for sampleType in HealthKitDataTypes.healthKitDataSampleTypes {
            healthKitDataStore.getSampleDataWithInDates(sampleType,
                                                        startDate: NSDate.distantPast(),
                                                        endDate: NSDate(),
                                                        limit: 2,
                                                        ascendingValue: true,
                                                        completion: { (result) in
                                                            //print(result.dataSamples)
            })
        }
    }
}
