//
//  ATMapViewController.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Mapbox
import MapboxDirections
import UIKit

class ATMapViewController: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet var mapView: MGLMapView!
    
    // MARK: - Mapbox
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor.orangeColor()
    }
    
    func addAnnotations() {
        let me = MGLPointAnnotation()
        me.coordinate = CLLocationCoordinate2D(latitude: 40.733683, longitude: -73.9911419)
        me.title = "Home"
        me.subtitle = "New York, NY"
        
        let station = MGLPointAnnotation()
        station.coordinate = CLLocationCoordinate2D(latitude: 40.7184948, longitude: -73.9962917)
        station.title = "2nd Av"
        station.subtitle = "Subway Station"
        
        let flatiron = MGLPointAnnotation()
        flatiron.coordinate = CLLocationCoordinate2D(latitude: 40.70528, longitude: -74.014025)
        flatiron.title = "Flatiron School"
        flatiron.subtitle = "Bowling Green Offices"
        
        mapView.addAnnotation(me)
        mapView.addAnnotation(station)
        mapView.addAnnotation(flatiron)
    }
    
    func drawPath() {
        let directions = Directions(accessToken: Keys.mapBoxToken)
        
        let waypoints = [
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 40.733683, longitude: -73.9911419), name: "Me"),
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 40.7184948, longitude: -73.9962917), name: "2 Av"), // Won't end at last waypoint
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 40.70528, longitude: -74.014025), name: "Flatiron")
        ]
        
        let options = RouteOptions(waypoints: waypoints, profileIdentifier: MBDirectionsProfileIdentifierWalking)
        options.includesSteps = true
        
        directions.calculateDirections(options: options) { (waypoints, routes, error) in
            guard error == nil else {
                print("Error getting directions: \(error!)")
                return
            }
            
            if let route = routes?.first, let leg = route.legs.first {
                print("Route via \(leg)")
                
                let distanceFormatter = NSLengthFormatter()
                let formattedDistance = distanceFormatter.stringFromMeters(route.distance)
                
                let travelTimeFormatter = NSDateComponentsFormatter()
                travelTimeFormatter.unitsStyle = .Short
                let formattedTravelTime = travelTimeFormatter.stringFromTimeInterval(route.expectedTravelTime)
                
                print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
                
                for step in leg.steps {
                    print("\(step.instructions)")
                    let formattedDistance = distanceFormatter.stringFromMeters(step.distance)
                    print("— \(formattedDistance) —")
                }
                
                if route.coordinateCount > 0 {
                    // Convert the route’s coordinates into a polyline.
                    var routeCoordinates = route.coordinates!
                    let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
                    
                    // Add the polyline to the map and fit the viewport to the polyline.
                    self.mapView.addAnnotation(routeLine)
                    self.mapView.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: UIEdgeInsetsZero, animated: true)
                }
            }
        }
        
    }
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addAnnotations()
        // drawPath()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
