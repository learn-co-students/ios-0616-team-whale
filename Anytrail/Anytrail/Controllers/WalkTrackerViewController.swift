//
//  WalkTrackerViewController.swift
//  Anytrail
//
//  Created by Michael Amundsen on 8/12/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Mapbox

class WalkTrackerViewController: UIViewController {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    static var walkTrackerSession = WalkTracker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AppDelegate.activeWorkout {
            startButton.enabled = false
        }
        
        HealthKitDataStore.sharedInstance.authorizeHealthKit { error in
            print(error)
        }
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateLabels(_:)), userInfo: nil, repeats: true)
        timer.fire()
        
        let person = HealthKitUserData()
        person.getStepCountForToday { sum in
            print("Steps: \(sum)")
        }
        
        person.getActiveEnergyForToday { sum in
            print("Active: \(sum)")
        }
        
        person.getBasalEnergyForToday { sum in
            print("Basal: \(sum)")
        }
        
        person.getDistanceForToday { sum in
            print("Distance: \(sum)")
        }
        
        person.getExerciseForToday { sum in
            print("Exercise: \(sum)")
        }
        
        person.getFlightCountForToday { sum in
            print("Flights: \(sum)")
        }
        
        person.getWaterConsumptionToday { sum in
            print("Water: \(sum)")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabels(timer: NSTimer) {
        timeLabel.text = "\(WalkTrackerViewController.walkTrackerSession.currentWalkTime)"
        distanceLabel.text = "\(WalkTrackerViewController.walkTrackerSession.walkDistance)"
    }
    
    @IBAction func startTapped(sender: AnyObject) {
        WalkTrackerViewController.walkTrackerSession.startWalk()
        WalkTrackerViewController.walkTrackerSession.walkStartDate = NSDate()
        startButton.enabled = false
        stopButton.enabled = true
    }
    
    @IBAction func stopTapped(sender: AnyObject) {
        WalkTrackerViewController.walkTrackerSession.stopWalk()
        WalkTrackerViewController.walkTrackerSession = WalkTracker()
        startButton.enabled = true
        stopButton.enabled = false
    }
}
