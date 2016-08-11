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
    
    let store = ApisDataStore.sharedInstance
    
    @IBOutlet var mapView: MGLMapView!
    
    // MARK: - Mapbox
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor.orangeColor()
    }
    
    func addFoursquareAnnotations() {
        
        for location in store.foursquareDataArray {
            let pin = MGLPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: location.placeLatitude, longitude: location.placeLongitude)
            pin.title = location.placeName
            
            pin.subtitle = location.placeAddress
            mapView.addAnnotation(pin)
            
        }
        
    }
    
    func addTrailsAnnotations() {
        for trail in store.mashapeDataArray {
            if trail.isHiking == true {
                let pin = MGLPointAnnotation()
                pin.coordinate = CLLocationCoordinate2D(latitude: trail.placeLatitude, longitude: trail.placeLongitude)
                pin.title = trail.placeName
                //                pin.subtitle = trail.isHiking?.description
                mapView.addAnnotation(pin)
            }
            
        }
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
        
        UnderArmourAPIClient.getHikingOrWalkingIDs { (data) in
         print(data)
        }
        
        store.getUnderArmourActivityIdDataWithCompletion { 
           
        }
        
        MashapeAPIClient.getTrails { (data) in
            
        }
        
        FoursquareAPIClient.getQueryForSearchLandmarks { (data) in
            
        }
        
        store.getTrailsWithCompletion {
            self.addTrailsAnnotations()
        }
        
        store.getDataWithCompletion {
            self.addFoursquareAnnotations()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
