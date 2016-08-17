//
//  SurgeonGeneralTableViewController.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/17/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class SurgeonGeneralTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView = UITableView()
    
    let tobaccoFreeIcon : UIImage = UIImage(named: "tobacco-free")!
    let activityIcon : UIImage = UIImage(named: "activity")!
    let mentalHealthIcon : UIImage = UIImage(named: "mental-health")!
    let nutritionIcon : UIImage = UIImage(named: "nutrition")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
        
        tableView.registerNib(UINib(nibName: "UserProfileCell", bundle: nil), forCellReuseIdentifier: "userProfileCellData")
        
        
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120.0
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UserProfileCell = self.tableView.dequeueReusableCellWithIdentifier("userProfileCellData", forIndexPath: indexPath) as! UserProfileCell
        cell.userInteractionEnabled = true
        switch indexPath.row {
        case 0:
            cell.giveCellData(activityIcon, dataLabel: "Active Living")
            cell.dataLabel.textColor = UIColor.whiteColor()
            cell.userCellBackgroundView.backgroundColor = UIColor.redColor()
            return cell
        case 1:
            cell.giveCellData(mentalHealthIcon, dataLabel: "Emotional and Mental Well-Being")
            cell.dataLabel.textColor = UIColor.whiteColor()
            cell.userCellBackgroundView.backgroundColor = UIColor.blueColor()
            return cell
        case 2:
            cell.giveCellData(tobaccoFreeIcon, dataLabel: "Tobacco Free Living")
            cell.dataLabel.textColor = UIColor.whiteColor()
            cell.userCellBackgroundView.backgroundColor = UIColor.brownColor()
            return cell
        case 3:
            cell.giveCellData(nutritionIcon, dataLabel: "Healthy Eating")
            cell.dataLabel.textColor = UIColor.whiteColor()
            cell.userCellBackgroundView.backgroundColor = UIColor.greenColor()
            return cell
        default:
            cell.dataLabel?.text = "default cell returning"
            print("default case")
            return cell
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        <#code#>
    }
}
