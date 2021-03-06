//
//  SurgeonGeneralTableViewController.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/17/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class SurgeonGeneralTableViewController: UITableViewController {
    
    let tobaccoFreeIcon : UIImage = UIImage(named: "tobacco-free")!
    let activityIcon : UIImage = UIImage(named: "activity")!
    let mentalHealthIcon : UIImage = UIImage(named: "mental-health")!
    let nutritionIcon : UIImage = UIImage(named: "nutrition")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.registerNib(UINib(nibName: "UserProfileCell", bundle: nil), forCellReuseIdentifier: "userProfileCellData")
        
        
        tableView.registerNib(UINib(nibName: "TipsCell", bundle: nil), forCellReuseIdentifier: "TipsCell")
        //
        //        let header:TipsAndTricksHeader = UINib(nibName: "TipsAndTricksHeader", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! TipsAndTricksHeader
        //       header.headerPhoto.image = UIImage(named: "surgeon-general")
        
        //        self.tableView.tableHeaderView = header
        
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.edgesForExtendedLayout = UIRectEdge.All
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, CGRectGetHeight((self.tabBarController?.tabBar.frame)!), 0.0)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120.0
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UserProfileCell = self.tableView.dequeueReusableCellWithIdentifier("userProfileCellData", forIndexPath: indexPath) as! UserProfileCell
        cell.userInteractionEnabled = true
        cell.selectionStyle = .None
        
        switch indexPath.row {
        case 0:
            cell.giveCellData(activityIcon, dataLabel: "Active Living")
            return cell
        case 1:
            cell.giveCellData(mentalHealthIcon, dataLabel: "Well-Being")
            return cell
        case 2:
            cell.giveCellData(tobaccoFreeIcon, dataLabel: "Tobacco Free Living")
            return cell
        case 3:
            cell.giveCellData(nutritionIcon, dataLabel: "Healthy Eating")
            return cell
        default:
            print("default case")
            return cell
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("TipsVC", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TipsVC" {
            if let destinationVC = segue.destinationViewController as? TipsAndTricksViewController {
                let path = tableView.indexPathForSelectedRow
                destinationVC.categoryNumber = (path?.row)!
            }
        }
    }
}