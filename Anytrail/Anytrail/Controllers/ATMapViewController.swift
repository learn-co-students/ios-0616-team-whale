//
//  ATMapViewController.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Mapbox
import MapboxDirections
import MapboxGeocoder

import UIKit

class ATMapViewController: UIViewController, MGLMapViewDelegate, ATDropdownViewDelegate {
    
    @IBOutlet var mapView: MGLMapView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dropdownBarButton: UIBarButtonItem!
    
    let store = ApisDataStore.sharedInstance
    var geocoder: Geocoder!
    
    var gestureRecognizer: UILongPressGestureRecognizer! = nil // Use for dropping destination pin
    
    var drawMode: Bool = false
    var pins: [MGLAnnotation] = []
    
    var dropdownView: ATDropdownView! = nil
    var dropdownDisplayed = false
    
    // MARK: - Actions
    
    @IBAction func dropdown() {
        if dropdownDisplayed {
            dropdownBarButton.image = UIImage(named: "dropdown")
            
            dropdownView.hide()
            dropdownDisplayed = false
        } else {
            dropdownBarButton.image = UIImage(named: "dropdown-up")
            
            dropdownView.show()
            dropdownDisplayed = true
        }
    }
    
    @IBAction func draw() {
        drawMode = true
        
        // Change color of pins when selected to indicate
        // which are the selected waypoints
    }
    
    // MARK: - Mapbox
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor.darkGrayColor()
    }
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        // Add annotation to selected point to pass
        // Be sure to check for duplicates (e.g same pin)
        //
        // Maybe add overlayed list of selected waypoints?
        // Or badge for counter on selected points icon
        // Color pin if selected
        
        if drawMode {
            // Confirm/Undo?
            ATAlertView.alertWithTitle(self, title: "Waypoint", text: "Selected \(annotation.title!!)", callback: {
                self.pins.append(annotation)
                return
            })
        }
        
        // Otherwise, display point info?
    }
    
    func geocodeWithQuery(query: String) {
        let options = ForwardGeocodeOptions(query: query)
        
        // Limit the search radius
        // options.focalLocation = mapView.userLocation?.location
        
        geocoder.geocode(options: options) { (placemarks, attribution, error) in
            if error == nil {
                let placemark = placemarks![0]
                
                let pin = MGLPointAnnotation()
                pin.coordinate = placemark.location.coordinate
                pin.title = placemark.name
                pin.subtitle = placemark.qualifiedName
                
                self.mapView.addAnnotation(pin)
            }
        }
    }
    
    // MARK: - Dropdown Delegate
    
    func dropdownDidUpdateOrigin(location: String) {
        if location.characters.count > 3 {
            geocodeWithQuery(location)
        }
    }
    
    func dropdownDidUpdateDestination(location: String) {
        if location.characters.count > 3 {
            geocodeWithQuery(location)
        }
    }
    
    // MARK: - Foursquare API
    
    func addFoursquareAnnotations() {
        ApisDataStore.sharedInstance.getDataWithCompletion {
            for location in self.store.foursquareData {
                let pin = MGLPointAnnotation()
                pin.coordinate = CLLocationCoordinate2D(latitude: location.placeLatitude, longitude: location.placeLongitude)
                pin.title = location.placeName
                pin.subtitle = location.placeAddress
                
                self.mapView.addAnnotation(pin)
            }
        }
    }
    
    // MARK: - Trails API
    
    func addTrailsAnnotations() {
        for trail in store.mashapeData {
            if trail.isHiking == true {
                let pin = MGLPointAnnotation()
                pin.coordinate = CLLocationCoordinate2D(latitude: trail.placeLatitude, longitude: trail.placeLongitude)
                pin.title = trail.placeName
                // pin.subtitle = trail.isHiking?.description
                
                mapView.addAnnotation(pin)
            }
        }
    }
    
    // MARK: - Paths
    
    func drawPath() {
        if pins.count < 2 {
            ATAlertView.alertWithTitle(self, title: "Paths", text: "Please select at least two points to pass", callback: {
                return
            })
        }
        
        var waypoints: [Waypoint] = []
        
        for pin in pins {
            let waypoint = Waypoint(coordinate: pin.coordinate)
            waypoints.append(waypoint)
        }
        
        let directions = Directions(accessToken: Keys.mapBoxToken)
        
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
                    // print("\(step.instructions)")
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
    
    func dropPin(tap: UIGestureRecognizer) {
        let location: CLLocationCoordinate2D = mapView.convertPoint(tap.locationInView(mapView), toCoordinateFromView: mapView)
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        
        // var coordinates: [CLLocationCoordinate2D] = [mapView.centerCoordinate, location]
        
        // if mapView.annotations?.count != nil {
        //     mapView.removeAnnotations(mapView.annotations!)
        // }
        
        let pin = MGLPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "Hello!"
        pin.subtitle = "You placed me at (\(coordinate.latitude), \(coordinate.longitude))"
        
        // Check if pins array already contains pin
        
        pins.append(pin)
        mapView.addAnnotation(pin)
        
        if let annotations = mapView.annotations {
            for pin in annotations {
                print("Pin: \(pin.coordinate)")
            }
        }
        
        // let polyline = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        // mapView.addAnnotation(polyline)
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        geocoder = Geocoder(accessToken: Keys.mapBoxToken)
        
        dropdownView = ATDropdownView(view: self.view)
        dropdownView.delegate = self
        
        // Custom path drawing
        // gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(dropPin))
        // mapView.addGestureRecognizer(gestureRecognizer)
        
        //        addFoursquareAnnotations()
        
        //        MashapeAPIClient.getTrails { (data) in
        //
        //        }
        //
        //        ApisDataStore.sharedInstance.getTrailsWithCompletion {
        //            self.addTrailsAnnotations()
        //        }
        //
        //        ApisDataStore.sharedInstance.getDataWithCompletion {
        //            self.addFoursquareAnnotations()
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
