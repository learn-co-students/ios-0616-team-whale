//
//  HealthDataViewController.swift
//  Anytrail
//
//  Created by Michael Amundsen on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class HealthDataViewController: UIViewController {
    
    let healthKitStore = HealthKitDataStore.healthKitStore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        HealthKitClient().authorizeHealthKit { (response) in
            print(response.success)
            print(response.error)
        }
        
        
        //        healthKitStore.prepareHealthKitTypesToRead()
        //        healthKitStore.prepareHealthKitTypesToWrite()
        //        healthKitStore.authorizeHealthKit { (response) in
        //            print(response.success)
        //            print(response.error)
        //        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
