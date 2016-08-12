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
    
    let walkTrackerSharedSession = WalkTracker.walkTrackerSharedSession
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateLabels(_:)), userInfo: nil, repeats: true)
        timer.fire()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabels(timer: NSTimer) {
        timeLabel.text = "\(walkTrackerSharedSession.currentWalkTime)"
        distanceLabel.text = "\(walkTrackerSharedSession.walkDistance)"
    }
    
    @IBAction func startTapped(sender: AnyObject) {
        walkTrackerSharedSession.startWalk()
        startButton.enabled = false
        stopButton.enabled = true
        
    }
    
    @IBAction func stopTapped(sender: AnyObject) {
        walkTrackerSharedSession.stopWalk()
        startButton.enabled = true
        stopButton.enabled = false
        dismissViewControllerAnimated(true) { 
            
        }
    }
    
    
}
