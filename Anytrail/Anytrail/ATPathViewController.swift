//
//  ATPathViewController.swift
//  Anytrail
//
//  Created by Sergey Nevzorov on 8/15/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import MapboxStatic

class ATPathViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    let store = AnytrailKit.sharedInstance
    var routes: [FullPath] = []
    
    // MARK: - Mapbox Static
    
    func getMapSnapshot(route: FullPath, size: CGSize, completion: (UIImage?) -> ()) {
        var waypoints: [CLLocationCoordinate2D] = []
        
        for point in (route.waypoints?.enumerate())! {
            waypoints.append(CLLocationCoordinate2DMake(Double(point.element.latitude!), Double(point.element.longitude!)))
        }
        
        let options = SnapshotOptions(
            mapIdentifiers: [Keys.mapBoxMapId],
            centerCoordinate: waypoints[1],
            zoomLevel: 12,
            size: size)
        
        let path = Path(coordinates: waypoints)
        path.fillColor = UIColor.darkGrayColor()
        path.strokeWidth = 4
        
        options.overlays = [path]
        
        let snapshot = Snapshot(
            options: options,
            accessToken: Keys.mapBoxToken)
        
        snapshot.image { (image, error) in
            if error == nil {
                completion(image)
            } else {
                print("Error fetching static map: \(error)")
                completion(nil)
            }
        }
    }
    
    // MARK: - Table
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CellId", forIndexPath: indexPath) as! ATPathCell
        
        let path = routes[indexPath.row]
        
        cell.dateLabel.text = formatDate(path.createdAt!)
        cell.durationLabel.text = "\(path.duration!)"
        
        getMapSnapshot(path, size: cell.mapImage.frame.size) { (image) in
            cell.mapImage.image = image
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .Normal, title: "Share") { (action: UITableViewRowAction, indexPath: NSIndexPath!) in
            // let firstActivityItem = self.date[indexPath.row]
            // let activityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
            // self.presentViewController(activityViewController, animated: true, completion: nil)
        }
        
        shareAction.backgroundColor = UIColor.blueColor()
        
        return [shareAction]
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reload()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reload), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ATPathViewController {
    
    // MARK: - Date
    
    func formatDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        
        return formatter.stringFromDate(date)
    }
    
    func reload() {
        store.fetchData()
        routes = store.paths
        
        tableView.reloadData()
        
        if refreshControl != nil && refreshControl.refreshing {
            refreshControl.endRefreshing()
        }
    }
}
