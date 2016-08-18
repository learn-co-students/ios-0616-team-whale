//
//  ProfileTableViewController.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/14/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Mapbox

class ProfileTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView = UITableView()
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
        
        self.tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
        
        tableView.registerNib(UINib(nibName: "UserProfileCell", bundle: nil), forCellReuseIdentifier: "userProfileCellData")
        
        let header:ProfileMapHeader = UINib(nibName: "ProfileMapHeader", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ProfileMapHeader
        self.tableView.tableHeaderView = header
        
        header.pathsTakenLabel?.text = "12 paths"
        header.stepsWalkedLabel?.text = "10,000 steps"
        header.userNameLabel?.text = "Elli Scharlin"
        
        self.edgesForExtendedLayout = UIRectEdge.All
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, CGRectGetHeight((self.tabBarController?.tabBar.frame)!), 0.0)
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        HealthKitDataStore.sharedInstance.getUserTodayHealthKitData {
            self.healthDummy = HealthKitDataStore.sharedInstance.healthKitUserData
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 2
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Mark: TODO take out the switch here after testing.
        switch section {
        case 0:
            return 4
        default:
            return healthDummy.count
        }
//        return healthDummy.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UserProfileCell = self.tableView.dequeueReusableCellWithIdentifier("userProfileCellData", forIndexPath: indexPath) as! UserProfileCell
        cell.userInteractionEnabled = false
        cell.userCellBackgroundView?.layer.cornerRadius = 8.0

        switch indexPath.section {
        case 0:
            return cell
        default:
            
        let singleHealth = healthDummy[indexPath.row]
       
        switch(singleHealth.1) {
        case "steps":
            cell.giveCellData(stepsIcon, dataLabel: singleHealth.0)
            return cell
        case "flight":
            cell.giveCellData(flightsIcon, dataLabel: singleHealth.0)
            return cell
        case "distance":
            cell.giveCellData(distanceIcon, dataLabel: singleHealth.0)
            return cell
        case "workout":
            cell.giveCellData(workoutIcon, dataLabel: singleHealth.0)
            return cell
        case "energy-burn":
            cell.giveCellData(energyIcon, dataLabel: singleHealth.0)
            return cell
        case "water":
            cell.giveCellData(waterIcon, dataLabel: singleHealth.0)
            return cell
        case "exercise-time":
            cell.giveCellData(exerciseTimeIcon, dataLabel: singleHealth.0)
            return cell
        case "heartrate":
            cell.giveCellData(heartrateIcon, dataLabel: singleHealth.0)
            return cell
            
        default:
            cell.dataLabel?.text = "default cell returning"
            print("default case")
            return cell
            }
        }
        
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Test"
        default:
            return "Today"
            
            
        }
        
    }
}
