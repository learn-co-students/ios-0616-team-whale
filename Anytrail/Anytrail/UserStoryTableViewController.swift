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
    
    
    var userInfoCell: ProfileMapCell = ProfileMapCell()
    var stepsTakenCell: UserStoryCell = UserStoryCell()
    var flightsClimbedCell: UserStoryCell = UserStoryCell()
    var distanceTravelledCell: UserStoryCell = UserStoryCell()
    
    var imageHeader: MGLMapView = MGLMapView()
    
    override func loadView() {
        super.loadView()
        self.title = "Profile" //We need some kind of user data store where this information is stored, so it is easily accessible.
//        let dummySteps = "1000"
//        let dummyFlights = "50"
//        let dummyDistance = "102.1 mi"
//        
//        self.stepsTakenCell.dataIconView.image = UIImage(named: "steps-taken")
//        self.stepsTakenCell.dataLabel.text = "\(dummySteps) steps taken"
//    
//        self.flightsClimbedCell.dataIconView.image = UIImage.init(named: "flights-climbed")
//        self.flightsClimbedCell.dataLabel.text = "\(dummyFlights) flights climbed"
//    
//        self.distanceTravelledCell.dataIconView.image = UIImage.init(named: "distance-travelled-map")
//        self.distanceTravelledCell.dataLabel.text = "\(dummyDistance) travelled"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         This is the part where we instantiate the above tableview. It will display the User's information."
         */
        
        //        self.tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
        self.tableView.frame = UIScreen.mainScreen().bounds
        self.tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.tableView.separatorStyle = .None
        
//        self.imageHeader.styleURL = NSURL(string: "mapbox://styles/imryan/cirhys2ik000igjnoz92eencj")
        
        
//        
//        let testHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 100))
//        testHeaderView.backgroundColor = UIColor.purpleColor()
//        self.tableView.tableHeaderView = testHeaderView
        
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
        
    }
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UserStoryCell()
        print(cell)
        cell.dataLabel.text = "test"
        return cell
//        switch(indexPath.section) {
//        case 0:
//            switch(indexPath.row) {
//            case 0: return self.stepsTakenCell
//            case 1: return self.flightsClimbedCell
//            case 2: return self.distanceTravelledCell
//            default: fatalError("Unknown row in section")
//            }
//        case 1:
//            switch(indexPath.row) {
//            case 0: return self.stepsTakenCell
//            case 1: return self.flightsClimbedCell
//            case 2: return self.distanceTravelledCell
//            default: fatalError("Unknown row in section")
//            }
//        case 2:
//            switch(indexPath.row) {
//            case 0: return self.stepsTakenCell
//            case 1: return self.flightsClimbedCell
//            case 2: return self.distanceTravelledCell
//            default: fatalError("Unknown row in section")
//            }
//        default:
//            fatalError("whoops")
//        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0: return "Today"
        case 1: return "Yesterday"
        case 2: return "\(dayOfTheWeek.last)"
        default: return "default day"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //    func updateHealthKitData
    
    
    
}
