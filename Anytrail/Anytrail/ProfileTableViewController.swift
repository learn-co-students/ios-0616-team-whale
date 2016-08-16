//
//  ProfileTableViewController.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/14/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Mapbox

class ProfileTableViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    
    var tableView: UITableView = UITableView()
    let hkStore = HealthKitDataStore.sharedInstance
    let healthDummy = [("10000","steps"), ("3","flight"),("10.5 mi", "distance"), ("3","workout"), ("4000 cal","energy-burn"),("3 oz","water"), ("60bpm","heartrate"), ("3h","exercise-time")]

    var userInfoCell: ProfileMapHeader = ProfileMapHeader()

    
    
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
        /*
         This is the part where we instantiate the above tableview. It will display the User's information."
         */
        
        self.tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: UITableViewStyle.Plain)
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
        
        self.tableView.backgroundColor = UIColor.whiteColor()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return healthDummy.count
        
        
    }
    
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UserProfileCell = self.tableView.dequeueReusableCellWithIdentifier("userProfileCellData", forIndexPath: indexPath) as! UserProfileCell
        
        
        
        
        
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
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Today"
        
        
        
        //    func updateHealthKitData
        
        
    }
}
