//
//  UserStoryViewController.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/14/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Mapbox

class UserStoryViewController: UIViewController {
    @IBOutlet weak var flightsClimbedLabel: UILabel!
    @IBOutlet weak var distanceTravelledLabel: UILabel!
    
    
    let walkTrackerSharedSession = WalkTracker.walkTrackerSharedSession
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
