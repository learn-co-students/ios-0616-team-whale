//
//  UserStoryTableViewController.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/14/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Mapbox

class UserStoryTableViewController: UITableViewController {

    let hkStore = HealthKitDataStore.sharedInstance
    @IBOutlet weak var iconForCell: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var reuseIdentifier:String = ""
        switch indexPath {
        case 1:
            reuseIdentifier = "stepsTaken"
        case 2:
            reuseIdentifier = "flightsClimbed"
        case 3:
            reuseIdentifier = "distanceTravelled"
        default:
            reuseIdentifier = "mapCell"
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        switch reuseIdentifier {
        case "stepsTaken":
//            cell.textLabel?.text = hkStore.getSampleDataWithInDates(HealthKitDataTypes.stepCount, startDate: NSDate.init(), endDate: NSDate.distantFuture(), limit: , ascendingValue: <#T##Bool#>, completion: { (<#healthKitSamplesData#>) in
        case "flightsClimbed":
        case "distanceTravelled":
            
        default:
            //"mapCell"
        
        }

        //        let data : FoursquareData = self.store.data[indexPath.row]
        //        cell.textLabel?.text = data.placeName
        
        
        
        return cell
    }
    
//    func updateHealthKitData
    

    
}
