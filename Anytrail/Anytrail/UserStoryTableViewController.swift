//
//  UserStoryTableViewController.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/14/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Mapbox

class UserStoryTableViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    
    var tableView: UITableView = UITableView()
    let hkStore = HealthKitDataStore.sharedInstance
    
    var userInfoCell: ProfileMapHeader = ProfileMapHeader()
    var stepsTakenCell: UserStoryCell = UserStoryCell()
    var flightsClimbedCell: UserStoryCell = UserStoryCell()
    var distanceTravelledCell: UserStoryCell = UserStoryCell()
    
    
    let stepsIcon : UIImage = UIImage(named: "steps-taken")!
    let flightsIcon : UIImage = UIImage(named: "flights-climbed")!
    let distanceIcon : UIImage = UIImage(named: "distance-travelled-map")!
    
    
 
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
        
        tableView.registerNib(UINib(nibName: "UserStoryCell", bundle: nil), forCellReuseIdentifier: "userDataCell")
        
        let header:ProfileMapHeader = UINib(nibName: "ProfileMapHeader", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ProfileMapHeader
        self.tableView.tableHeaderView = header
        
        
        header.pathsTakenLabel?.text = "12 paths"
        header.stepsWalkedLabel?.text = "10,000 steps"
        header.userNameLabel?.text = "Elli Scharlin"
        
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
        
        
    }
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let healthDummy = [("10000","steps"), ("3","flight"),("10.5 mi", "distance")]
        
        let cell: UserStoryCell = self.tableView.dequeueReusableCellWithIdentifier("userDataCell", forIndexPath: indexPath) as! UserStoryCell
        
        
        
        
        
        let singleHealth = healthDummy[indexPath.row]
        
//            switch(singleHealth.1) {
//            case "steps":
//                cell.giveCellData(UIImageView(image: stepsIcon), dataLabel: "steps data")
//
////                cell.dataIconView = UIImageView(image: stepsIcon)
////                cell.dataLabel?.text = singleHealth.0
//                print("steps case")
//                return cell
//            case "flight":
//                cell.giveCellData(UIImageView(image: flightsIcon), dataLabel: "flights data")
//
////                cell.dataIconView = UIImageView(image: flightsIcon)
////                cell.dataLabel?.text = singleHealth.0
//                print("flights case")
//                return cell
//            case "distance":
//                cell.giveCellData(UIImageView(image: distanceIcon), dataLabel: "distance data")
                cell.dataIconView = UIImageView(image: distanceIcon)
        cell.dataLabel?.text = "DATAAAA:"//singleHealth.0
                print("distance case")
                return cell
//            default:
//                cell.dataLabel?.text = "default cell returning"
//                print("default case")
//                return cell
//                
//                
//                
//                
//            }
        

    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Today"
        
        
        
        //    func updateHealthKitData
        
        
    }
}
