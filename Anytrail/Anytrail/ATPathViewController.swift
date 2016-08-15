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
       return 5
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
