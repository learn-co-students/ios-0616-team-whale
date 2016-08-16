//
//  ATPathViewController.swift
//  Anytrail
//
//  Created by Sergey Nevzorov on 8/15/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ATPathViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var images = [UIImage(named: "path1"), UIImage(named: "path2"), UIImage(named: "path3"), UIImage(named: "path4"), UIImage(named: "path5")]
    var date = ["June 12, 2016", "July 8, 2016", "August 2, 2016", "August 19, 2016", "August 23, 2016"]
    var location = ["New York", "Boston", "Bennington", "Cape May", "Chicago"]
    var distance = ["2.5 mi", "4.8 mi", "9.3 mi", "6.1 mi", "12.4"]
    var steps = ["5.934", "12.372", "24.153", "14.942", "28.337"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.date.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ATPathCell
        
        cell.mapImage.image = images[indexPath.row]
        cell.dateLabel.text = date[indexPath.row]
        cell.locationLabel.text = location[indexPath.row]
        cell.distanceLabel.text = distance[indexPath.row]
        cell.stepsLabel.text = steps[indexPath.row]
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "detailVC" {
            if let destinationVC = segue.destinationViewController as? ATPathDetailedController {
                
                let path = tableView.indexPathForSelectedRow
                guard let cell = tableView.cellForRowAtIndexPath(path!) as? ATPathCell else { return }
                destinationVC.imageDetail = (cell.mapImage.image)!
                
            }
        }
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//        _ = tableView.indexPathForSelectedRow
//        if let _ = tableView.cellForRowAtIndexPath(indexPath) {
//            self.performSegueWithIdentifier("detailVC", sender: self)
//        }
    //}
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .Normal, title: "Share") { (action: UITableViewRowAction, indexPath: NSIndexPath!) in
            let firstActivityItem = self.date[indexPath.row]
            let activityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
        shareAction.backgroundColor = UIColor.blueColor()
        
        return [shareAction]
    }
}
