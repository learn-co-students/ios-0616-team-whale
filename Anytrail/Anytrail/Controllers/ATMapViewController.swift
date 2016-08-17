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
    @IBOutlet weak var drawRouteButton: UIBarButtonItem!
    
    let store = ApisDataStore.sharedInstance
    let locationStore = LocationDataStore.sharedInstance
    var geocoder: Geocoder!
    
    var gestureRecognizer: UILongPressGestureRecognizer! = nil
    
    var origin: ATAnnotation! = nil
    var destination: ATAnnotation! = nil
    
    var createMode: Bool = false
    var pins: [MGLAnnotation] = []
    var pointsOfInterest: [ATAnnotation] = []
    
    var dropdownView: ATDropdownView! = nil
    var dropdownDisplayed = false
    
    // This is used to track the 'stage' in the path lifecycle
    // 1 => Default, setting origin and destination
    // 2 => Waypoints, selecting waypoints
    // 3 => Route, creating final route
    
    enum ATCurrentStage: Int {
        case Default = 1
        case Waypoints = 2
        case Route = 3
    }
    
    var currentStage: ATCurrentStage!
    
    // MARK: - ATDropdownView
    
    func dropdownDidUpdateOrigin(location: String) {
        if location.characters.count > 3 {
            geocodeWithQuery(location, type: .Origin)
        }
    }
    
    func dropdownDidUpdateDestination(location: String) {
        if location.characters.count > 3 {
            geocodeWithQuery(location, type: .Destination)
        }
    }
    
    func reshowDropdown(withView view: ATDropdownView.ATDropownViewType, hintText: String) {
        if !dropdownDisplayed {
            dropdownView.changeDropdownView(view)
            dropdownView.updateHintLabel(hintText)
            dropdownView.show()
            
        } else {
            dropdownView.hide()
            
            delay(0.3, block: {
                self.dropdownView.changeDropdownView(view)
                self.dropdownView.updateHintLabel(hintText)
                self.dropdownView.show()
            })
        }
    }
    
    // MARK: - Actions
    
    @IBAction func dropdown() {
        if currentStage == .Default {
            if dropdownDisplayed {
                dropdownBarButton.image = UIImage(named: "dropdown")
                
                dropdownView.hide()
                dropdownDisplayed = false
            } else {
                dropdownBarButton.image = UIImage(named: "dropdown-up")
                
                dropdownView.show()
                dropdownDisplayed = true
            }
            
        } else {
            currentStage = .Default
            reshowDropdown(withView: .Default, hintText: "")
            
            UIView.animateWithDuration(0.3, animations: {
                self.dropdownBarButton.image = UIImage(named: "dropdown")
            })
            
            removeWaypoints()
            removeUnusedWaypoints()
        }
    }
    
    @IBAction func create() {
        if currentStage == .Default {
            createMode = true
            addFoursquareAnnotations()
            currentStage = .Waypoints
            
            UIView.animateWithDuration(0.3, animations: {
                self.dropdownBarButton.image = UIImage(named: "back-arrow")
            })
            
            reshowDropdown(withView: .Label, hintText: "Now let's select a few points of interest to pass by")
            
        } else if currentStage == .Waypoints {
            // Waypoints selected, sort and generate route
            // Change icon to GO
            if pins.count > 0 {
                currentStage = .Route
            } else {
                ATAlertView.alertWithTitle(self, type: .Error, title: "Whoops", text: "Select at least one point to pass", callback: {
                    return
                })
            }
            
            createPath()
        }
    }
    
    // MARK: - Mapbox
    
    func mapView(mapView: MGLMapView, didUpdateUserLocation userLocation: MGLUserLocation?) {
        if let location = mapView.userLocation {
            mapView.setCenterCoordinate(location.coordinate, animated: true)
        }
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor.darkGrayColor()
    }
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        if annotation.isKindOfClass(MGLUserLocation) {
            return
        }
        
        if createMode {
            if coordinatesEqual(annotation.coordinate, other: origin.coordinate) {
                ATAlertView.alertWithTitle(self, type: .Origin, title: origin.title!, text: "This is your origin.", callback: {
                    mapView.deselectAnnotation(annotation, animated: true)
                    return
                })
            } else if coordinatesEqual(annotation.coordinate, other: destination.coordinate) {
                ATAlertView.alertWithTitle(self, type: .Error, title: destination.title!, text: "This is your destination.", callback: {
                    mapView.deselectAnnotation(annotation, animated: true)
                    return
                })
            }
            
            let pin = annotation as! ATAnnotation
            pin.type = .Waypoint
            
            if self.containsPin(pin) {
                ATAlertView.alertWithConfirmation(self, title: annotation.title!!, text: "Information about this place.", action: "Remove", callback: {
                    self.pointsOfInterest.append(pin)
                    
                    if let index = self.pins.indexOf({ $0.title! == pin.title! }) {
                        self.pins.removeAtIndex(index)
                    }
                    
                    let pin = annotation as! ATAnnotation
                    pin.type = .PointOfInterest
                    
                    let annotationView = mapView.viewForAnnotation(annotation)
                    annotationView?.backgroundColor = pin.backgroundColor
                    
                    if let index = self.pointsOfInterest.indexOf(pin) {
                        self.pointsOfInterest.removeAtIndex(index)
                    }
                    
                    mapView.deselectAnnotation(annotation, animated: true)
                    return
                    
                    }, cancelCallback: {
                        mapView.deselectAnnotation(annotation, animated: true)
                        return
                })
            }
            
            // TODO: Fill text with cool detail info
            
            ATAlertView.alertWithConfirmation(self, title: annotation.title!!, text: "Information about this place.", action: "Add", callback: {
                self.pins.append(annotation)
                
                let pin = annotation as! ATAnnotation
                pin.type = .Waypoint
                
                let annotationView = mapView.viewForAnnotation(annotation)
                annotationView?.backgroundColor = pin.backgroundColor
                
                if let index = self.pointsOfInterest.indexOf(pin) {
                    self.pointsOfInterest.removeAtIndex(index)
                }
                
                mapView.deselectAnnotation(annotation, animated: true)
                return
                
                }, cancelCallback: {
                    mapView.deselectAnnotation(annotation, animated: true)
                    return
            })
        }
        
        // Otherwise, display POI info?
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
            
            let pin = annotation as! ATAnnotation
            annotationView?.backgroundColor = pin.backgroundColor
        }
        
        return annotationView
    }
    
    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(annotation, animated: true)
    }
    
    func geocodeWithQuery(query: String, type: ATAnnotation.ATAnnotationType) {
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
                        let pin = ATAnnotation()
                        
                        pin.coordinate = placemark.location.coordinate
                        pin.title = placemark.name
                        pin.subtitle = placemark.qualifiedName
                        pin.type = type
                        
                        if type == .Origin {
                            self.assignOrigin(pin)
                            return
                            
                        } else if type == .Destination {
                            self.assignDestination(pin)
                            return
                        }
                        
                        if !self.pinIsDuplicate(pin) {
                            self.pins.append(pin)
                            self.mapView.addAnnotation(pin)
                            
                        } else {
                            // Pin already exists
                        }
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
                    completion(address: placemarks[0].name)
                }
            } else {
                print("Error reverse-geocoding: \(error)")
                completion(address: nil)
            }
        }
    }
    
    // MARK: - Foursquare API
    
    func addFoursquareAnnotations() {
        // Assign here
        locationStore.origin = origin.coordinate
        locationStore.destination = destination.coordinate
        
        locationStore.settingRectangleForFoursquare()
        
        ApisDataStore.sharedInstance.getDataWithCompletion {
            for location in self.store.foursquareData {
                let pin = ATAnnotation()
                
                pin.coordinate = CLLocationCoordinate2D(latitude: location.placeLatitude, longitude: location.placeLongitude)
                pin.title = location.placeName
                pin.subtitle = location.placeAddress
                pin.type = .PointOfInterest
                
                self.pointsOfInterest.append(pin)
                self.mapView.addAnnotation(pin)
            }
        }
    }
    
    // MARK: - Trails API
    
    func addTrailsAnnotations() {
        for trail in store.mashapeData {
            if trail.isHiking == true {
                let pin = ATAnnotation()
                
                pin.coordinate = CLLocationCoordinate2D(latitude: trail.placeLatitude, longitude: trail.placeLongitude)
                pin.title = trail.placeName
                pin.subtitle = trail.isHiking?.description
                pin.type = .PointOfInterest
                
                mapView.addAnnotation(pin)
            }
        }
    }
    
    // MARK: - Paths
    
    func assignOrigin(origin: ATAnnotation) {
        if self.origin != nil {
            self.mapView.removeAnnotation(self.origin)
        }
        
        self.origin = origin
        self.mapView.addAnnotation(origin)
        
        if origin == "" {
            if let _ = mapView.userLocation {
                // Assume current location
            }
        }
        
        if canCreatePath() {
            drawRouteButton.enabled = true
        } else {
            drawRouteButton.enabled = false
        }
    }
    
    func assignDestination(destination: ATAnnotation) {
        if self.destination != nil {
            self.mapView.removeAnnotation(self.destination)
        }
        
        self.destination = destination
        self.mapView.addAnnotation(destination)
        
        if canCreatePath() {
            drawRouteButton.enabled = true
        } else {
            drawRouteButton.enabled = false
        }
    }
    
    func createPath() {
        removeUnusedWaypoints()
        
        var waypoints: [Waypoint] = []
        
        for pin in pins {
            let waypoint = Waypoint(coordinate: pin.coordinate)
            waypoints.append(waypoint)
        }
        
        // TODO: Sort waypoints
        
        
        let originWaypoint = Waypoint(coordinate: origin.coordinate)
        let destinationWaypoint = Waypoint(coordinate: destination.coordinate)
        
        waypoints.insert(originWaypoint, atIndex: 0)
        waypoints.insert(destinationWaypoint, atIndex: waypoints.endIndex-1)
        
        // Directions
        
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
                    var routeCoordinates = route.coordinates!
                    let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
                    
                    self.mapView.addAnnotation(routeLine)
                    self.mapView.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: UIEdgeInsetsZero, animated: true)
                }
            }
        }
    }
    
    //    func dropPin(tap: UIGestureRecognizer) {
    //        let location: CLLocationCoordinate2D = mapView.convertPoint(tap.locationInView(mapView), toCoordinateFromView: mapView)
    //        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    //
    //        let pin = MGLPointAnnotation()
    //        pin.coordinate = coordinate
    //        pin.title = "Hello!"
    //        pin.subtitle = "You placed me at (\(coordinate.latitude), \(coordinate.longitude))"
    //
    //        if !pinIsDuplicate(pin) {
    //            pins.append(pin)
    //            mapView.addAnnotation(pin)
    //
    //        } else {
    //            ATAlertView.alertWithTitle(self, type: ATAlertView.ATAlertViewType.Normal, title: "Whoops", text: "You've already added this pin", callback: {
    //                return
    //            })
    //
    //            // May just return instead of alert
    //        }
    //
    //        //        if let annotations = mapView.annotations {
    //        //            for pin in annotations {
    //        //                print("Pin: \(pin.coordinate)")
    //        //            }
    //        //        }
    //
    //        // let polyline = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
    //        // mapView.addAnnotation(polyline)
    //    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        geocoder = Geocoder(accessToken: Keys.mapBoxToken)
        
        dropdownView = ATDropdownView(view: self.view)
        dropdownView.delegate = self
        
        currentStage = .Default
        
        // TODO: Implement for dropping origin/destination with alert prompt for each
        // gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(dropPin))
        // mapView.addGestureRecognizer(gestureRecognizer)
        
        // TODO: Implement these APIs
        //
        // MashapeAPIClient.getTrails { (data) in
        
        // }
        
        // ApisDataStore.sharedInstance.getTrailsWithCompletion {
        //     self.addTrailsAnnotations()
        // }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ATMapViewController {
    
    func coordinatesEqual(location: CLLocationCoordinate2D, other: CLLocationCoordinate2D) -> Bool {
        return location.latitude == other.latitude && location.longitude == other.longitude
    }
    
    func pinIsDuplicate(pin: MGLAnnotation) -> Bool {
        let coordinate = pin.coordinate
        
        for pin in pins {
            if coordinatesEqual(pin.coordinate, other: coordinate) {
                return true
            }
        }
        
        return false
    }
    
    func containsPin(pin: ATAnnotation) -> Bool {
        if pins.contains({ $0.title!! == pin.title! }) {
            return true
        }
        
        return false
    }
    
    func canCreatePath() -> Bool {
        return origin != nil && destination != nil
    }
    
    func removeWaypoints() {
        self.mapView.removeAnnotations(self.pins)
    }
    
    func removeUnusedWaypoints() {
        self.mapView.removeAnnotations(self.pointsOfInterest)
    }
    
    func delay(delay: NSTimeInterval, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), block)
    }
}


