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
            print(response.success)
            print(response.error)
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
                                                        limit: 0,
                                                        ascendingValue: true,
                                                        completion: { (result) in
                                                            print(result.dataSamples)
            })
        }
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
