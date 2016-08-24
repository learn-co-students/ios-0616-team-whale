//
//  ProfileTableViewController.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/14/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Mapbox
import Firebase
import FBSDKLoginKit

class ProfileTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView :UITableView = UITableView()
    var healthDummy: [(String, String)] = []
    let stepsIcon : UIImage = UIImage(named: "steps-taken")!
    let flightsIcon : UIImage = UIImage(named: "flights-climbed")!
    let distanceIcon : UIImage = UIImage(named: "distance-travelled-map")!
    let workoutIcon : UIImage = UIImage(named: "workout")!
    let waterIcon : UIImage = UIImage(named: "water")!
    let exerciseTimeIcon : UIImage = UIImage(named: "exercise-time")!
    let heartrateIcon : UIImage = UIImage(named: "heart-rate")!
    let energyIcon  : UIImage = UIImage(named: "energy-burn")!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: (CGRectMake(0, -30, self.view.bounds.size.width, self.view.bounds.size.height)), style: UITableViewStyle.Grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
        
        self.tableView.registerNib(UINib(nibName: "UserProfileCell", bundle: nil), forCellReuseIdentifier: "userProfileCellData")
        
        let header:ProfileMapHeader = UINib(nibName: "ProfileMapHeader", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ProfileMapHeader
        self.tableView.tableHeaderView = header
        
        if let authentification = FIRAuth.auth() {
            if let currentUser = authentification.currentUser {
                currentUser.fetchUserProfileImage({ (image) in
                    if let image = image {
                        header.profileImageView?.image = image
                    } else {
                        // Remain empty state
                    }
                })
                
                if let currentUserDisplay = currentUser.displayName {
                    header.userNameLabel?.text = "\(currentUserDisplay)"
                }
            }
        }
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        HealthKitDataStore.sharedInstance.authorizeHealthKit { error in
            print(error)
        }
        
        HealthKitDataStore.sharedInstance.getUserTodayHealthKitData {
            self.healthDummy = HealthKitDataStore.sharedInstance.healthKitUserData
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return healthDummy.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UserProfileCell = self.tableView.dequeueReusableCellWithIdentifier("userProfileCellData", forIndexPath: indexPath) as! UserProfileCell
        cell.userInteractionEnabled = false
        
        let singleHealth = healthDummy[indexPath.row]
        
        switch(singleHealth.1) {
        case "steps":
            cell.giveCellData(stepsIcon, dataLabel: "\(singleHealth.0) steps taken")
            return cell
        case "flight":
            cell.giveCellData(flightsIcon, dataLabel: "\(singleHealth.0) flights climbed")
            return cell
        case "distance":
            cell.giveCellData(distanceIcon, dataLabel: "\(singleHealth.0) miles travelled")
            return cell
        case "energy-burn":
            cell.giveCellData(energyIcon, dataLabel: "\(singleHealth.0) active calories")
            return cell
        case "resting-burn":
            cell.giveCellData(energyIcon, dataLabel: "\(singleHealth.0) resting calories")
            return cell
        case "water":
            cell.giveCellData(waterIcon, dataLabel: "\(singleHealth.0) water consumed")
            return cell
        case "exercise-time":
            cell.giveCellData(exerciseTimeIcon, dataLabel: "\(singleHealth.0) exercise minutes")
            return cell
        default:
            cell.dataLabel?.text = "default cell returning"
            print("default case")
            return cell
        }
        
        
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Today"
    }
}

