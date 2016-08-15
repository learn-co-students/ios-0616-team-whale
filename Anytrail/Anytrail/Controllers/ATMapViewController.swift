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
    
    var gestureRecognizer: UILongPressGestureRecognizer! = nil // Use for dropping origin/destination pin
    
    var drawMode: Bool = false
    var pins: [MGLAnnotation] = []
    
    var dropdownView: ATDropdownView! = nil
    var dropdownDisplayed = false
    
    var origin: MGLAnnotation!
    var destination: MGLPointAnnotation! = nil
    var waypoints: [Waypoint] = []
    
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
    
    func mapView(mapView: MGLMapView, didUpdateUserLocation userLocation: MGLUserLocation?) {
        if let location = mapView.userLocation {
             self.pins.append(location)
        }
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor.darkGrayColor()
    }
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        // Add annotation to selected point to pass
        // Be sure to check for duplicates (e.g same pin)
        // Color pin if selected

        if drawMode {
            // Confirm/Undo?
            ATAlertView.alertWithTitle(self, type: ATAlertView.ATAlertViewType.Success, title: "Waypoint" ,text: "Added \(annotation.title!!)", callback: {
                self.pins.append(annotation)
                return
            })
        }
        
        // Otherwise, display point info?
    }
    
    func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        let reuseIdentifier = "AnnotationId"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
        
        if annotationView == nil {
            annotationView = ATAnnotationView(reuseIdentifier: reuseIdentifier) 
            annotationView!.frame = CGRectMake(0, 0, 25, 25)
            
            let pin = annotationView as! ATAnnotationView
            pin.type = ATAnnotationView.ATAnnotationType.PointOfInterest
            
            // Determine type of pin and assign it
        }
        
        return annotationView
    }
    
//    func mapView(mapView: MGLMapView, leftCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
//        if annotation.isKindOfClass(MGLUserLocation) {
//            return nil
//        }
//        
//        // Change pin color once the pin has been formally selected
//        // Change waypoint-add image to waypoint-added
//
//    }
    
    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // Change image/color and dismiss
        
        // let buttonImageView = control.subviews[0] as! UIImageView
        // buttonImageView.image = UIImage(named: "waypoint-added")
        
        mapView.deselectAnnotation(annotation, animated: true)
    }
    
    func geocodeWithQuery(query: String) {
        let options = ForwardGeocodeOptions(query: query)
        options.focalLocation = mapView.userLocation?.location
        
        geocoder.geocode(options: options) { (placemarks, attribution, error) in
            if error == nil {
                if let placemarks = placemarks {
                    if placemarks.isEmpty {
                        ATAlertView.alertWithTitle(self, type: ATAlertView.ATAlertViewType.Error, title: "Whoops", text: "We couldn't find an address matching your query", callback: {
                            return
                        })
                        
                    } else {
                        let placemark = placemarks[0]
                        
                        let pin = MGLPointAnnotation()
                        pin.coordinate = placemark.location.coordinate
                        pin.title = placemark.name
                        pin.subtitle = placemark.qualifiedName
                        
                        self.mapView.addAnnotation(pin)
                        
                        // Load foursquare data when user initiates
                        // self.addFoursquareAnnotations()
                        
                        if !self.pinIsDuplicate(pin) {
                            self.pins.append(pin)
                            self.mapView.addAnnotation(pin)
                            
                        } else {
                            // Pin already exists as destination
                        }
                        
                        // Destination will always be inserted at end, after POIs are selected and route is starting
                        // print("Destination: \(self.destination.title)")
                        // self.pins.insert(pin, atIndex: self.pins.endIndex)
                        
                        
                        // TODO: Change this to remove specific destination pins
                        
                        self.mapView.removeAnnotations(self.mapView.annotations!)
                        self.assignDestination(pin)
                    }
                    
                } else {
                    ATAlertView.alertWithTitle(self, type: ATAlertView.ATAlertViewType.Error, title: "Whoops", text: "We couldn't find an address matching your query", callback: {
                        return
                    })
                }
            }
        }
    }
    
    func reverseGeocode(location: CLLocation, completion: (address: String?) -> ()) {
        let options = ReverseGeocodeOptions(location: location)
        
        geocoder.geocode(options: options) { (placemarks, attribution, error) in
            if error == nil {
                if let placemarks = placemarks {
                    completion(address: placemarks[0].qualifiedName)
                }
            } else {
                print("Error reverse-geocoding: \(error)")
                completion(address: nil)
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
    
    func assignDestination(destination: MGLPointAnnotation) {
        self.destination = destination
        self.mapView.addAnnotation(destination)
    }
    
    func addWaypoint(sender: UIButton) {
        // Add from pin callout view
        print("Add waypoint")
    }
    
    func drawPath() {
        if pins.count < 1 {
            ATAlertView.alertWithTitle(self, type: ATAlertView.ATAlertViewType.Normal, title: "Paths", text: "Please select at least one point to pass", callback: {
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
        
        if !pinIsDuplicate(pin) {
            pins.append(pin)
            mapView.addAnnotation(pin)
            
        } else {
            ATAlertView.alertWithTitle(self, type: ATAlertView.ATAlertViewType.Normal, title: "Whoops", text: "You've already added this pin", callback: {
                return
            })
            
            // May just return instead of alert
        }
        
//        if let annotations = mapView.annotations {
//            for pin in annotations {
//                print("Pin: \(pin.coordinate)")
//            }
//        }
        
        // let polyline = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        // mapView.addAnnotation(polyline)
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        geocoder = Geocoder(accessToken: Keys.mapBoxToken)
        
        dropdownView = ATDropdownView(view: self.view)
        dropdownView.delegate = self
        
        
        gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(dropPin))
        mapView.addGestureRecognizer(gestureRecognizer)
        
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

extension ATMapViewController {
    
    func pinIsDuplicate(pin: MGLAnnotation) -> Bool {
        let latitude = pin.coordinate.latitude
        let longitude = pin.coordinate.longitude
        
        for pin in pins {
            if pin.coordinate.latitude == latitude && pin.coordinate.longitude == longitude {
                return true
            }
        }
        
        return false
    }
}
