//
//  TipsAndTricksViewController.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/17/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class TipsAndTricksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var tableView: UITableView = UITableView()
    
    var categoryNumber : Int?
    let activeLiving: [String] = ["active living"]
    let wellbeing : [String] = ["Emotional and Mental Well-Being"]
    let tobaccoFreeLiving : [String] = ["tobacco free living"]
    let healthyEating : [String] = ["Healthy Eating"]
    var arraySentFromSegue: [String]?
    
    let leafIcon : UIImage = UIImage(named: "leaf")!
    var informationData: [[String]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        informationData = [activeLiving, wellbeing, tobaccoFreeLiving, healthyEating]
        arraySentFromSegue = informationData[categoryNumber!]
        
        self.tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
        
        tableView.registerNib(UINib(nibName: "UserProfileCell", bundle: nil), forCellReuseIdentifier: "userProfileCellData")
        
        
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraySentFromSegue!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UserProfileCell = self.tableView.dequeueReusableCellWithIdentifier("userProfileCellData", forIndexPath: indexPath) as! UserProfileCell
        cell.userInteractionEnabled = true
        cell.intrinsicContentSize()
        cell.dataIconView = leafIcon
        cell.dataLabel.text = arraySentFromSegue![indexPath.row]
    }
}
