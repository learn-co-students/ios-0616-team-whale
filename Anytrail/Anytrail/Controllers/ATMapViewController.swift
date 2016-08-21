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
    
    //var onceToken: dispatch_once_t = 0
    
    let store = ApisDataStore.sharedInstance
    let locationStore = LocationDataStore.sharedInstance
    var geocoder = Geocoder(accessToken: Keys.mapBoxToken)
    
    //var gestureRecognizer: UILongPressGestureRecognizer! = nil
    var originString = ""
    var destinationString = ""
    
    var origin: ATAnnotation?
    var destination: ATAnnotation?
    var routeLine: MGLPolyline?
    
    var createMode = false
    var waypoints: [ATAnnotation] = []
    var pointsOfInterest: [ATAnnotation] = []
    var foursquareDataResponse: [FoursquareData] = []
    
    var dropdownView: ATDropdownView!
    var dropdownDisplayed = false
    var navigationRoutes: [Route] = []
    var navigationLegs: [RouteLeg] = []
    
    // This is used to track the 'stage' in the path lifecycle
    // 1 => Default, setting origin and destination
    // 2 => Waypoints, selecting waypoints
    // 3 => Route, creating final route
    
    enum ATCurrentStage: Int {
        case Default
        case Waypoints
        case Route
    }
    
    var currentStage: ATCurrentStage!
    
    // MARK: - ATDropdownView
    
    func dropdownDidUpdateOrigin(location: String) {
        if originString != location && location.characters.count > 3 {
            originString = location
            geocodeWithQuery(location, type: .Origin) { originAnnotation in
                self.assignOrigin(originAnnotation)
            }
        }
    }
    
    func dropdownDidUpdateDestination(location: String) {
        if destinationString != location && location.characters.count > 3 {
            destinationString = location
            geocodeWithQuery(location, type: .Destination) { destinationAnnotation in
                self.assignDestination(destinationAnnotation)
            }
        }
    }
    
    func reshowDropdown(withView view: ATDropdownView.ATDropownViewType, hintText: String) {
        if !dropdownDisplayed {
            dropdownView.changeDropdownView(view)
            
            if view == .Label {
                dropdownView.updateHintLabel(hintText)
            }
            
            dropdownView.show()
            dropdownDisplayed = true
        } else {
            dropdownView.hide()
            
            delay(0.3, block: {
                self.dropdownView.changeDropdownView(view)
                
                if view == .Label {
                    self.dropdownView.updateHintLabel(hintText)
                }
                
                self.dropdownView.show()
                self.dropdownDisplayed = true
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
            
            UIView.animateWithDuration(0.3) {
                self.dropdownBarButton.image = UIImage(named: "dropdown")
            }
            self.tabBarController?.setTabBarVisible(true, animated: true)
            clearMapView()
        }
    }
    
    func setToDefaultWaypoints() {
        createMode = true
        
        currentStage = .Waypoints
        
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.3) {
                self.dropdownBarButton.image = UIImage(named: "back-arrow")
            }
        }
        getWaypoints()
    }
    
    func getWaypoints() {
        addFoursquareAnnotations() { count in
            self.reshowDropdown(withView: .Label, hintText: "Awesome! We found \(count) places to visit on your way.\nStart by selecting some!")
            dispatch_async(dispatch_get_main_queue()) {
                for pin in self.pointsOfInterest {
                    self.mapView.addAnnotation(pin)
                }
            }
        }
    }
    
    @IBAction func create() {
        if currentStage == .Default {
            setToDefaultWaypoints()
            
        } else if currentStage == .Waypoints {
            if (waypoints.count > 25) {
                let waypointPlural = abs(25 - waypoints.count) == 1 ? "waypoint" : "waypoints"
                ATAlertView.alertWithTitle(self, type: .Error, title: "Whoops", text: "Too many points selected. Remove \(abs(25 - waypoints.count)) \(waypointPlural)", callback: {
                    return
                })
                
            } else if waypoints.count > 0 {
                currentStage = .Route
                createPath({ (time) in
                    self.reshowDropdown(withView: .Label, hintText: "Your walk will take about \(time).\nEnjoy your walk to \(self.destination?.title)!")
                    
                    // self.tabBarController?.setTabBarVisible(false, animated: true)
                    // slide up start/stop
                })
                
            } else {
                ATAlertView.alertWithTitle(self, type: .Error, title: "Whoops", text: "Select at least one point to pass", callback: {
                    return
                })
            }
        }
    }
    
    
    @IBAction func navigateTapped(sender: AnyObject) {
        var waypointString = ""
        
        for pin in waypoints {
            waypointString = waypointString + "\(pin.coordinate.latitude)," + "\(pin.coordinate.longitude)&"
        }
        
        print(waypointString)
        
        //        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
        //            UIApplication.sharedApplication().openURL(NSURL(string:
        //                "comgooglemaps://?saddr=&daddr=\(place.latitude),\(place.longitude)&directionsmode=driving")!)
        //
        //        } else {
        //            NSLog("Can't use comgooglemaps://");
        //        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationTableView = segue.destinationViewController as? NavigationTableViewController
        destinationTableView?.legs = navigationLegs
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
        
        if createMode && currentStage == .Waypoints {
            
            guard let origin = origin, let destination = destination else {
                return
            }
            
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
            
            if self.containsWaypoint(pin) {
                ATAlertView.alertWithConfirmationForVenue(self, image: UIImage(named: "venue")!, title: annotation.title!!, text: "You are about to remove this place as a waypoint.", action: "Remove", callback: {
                    self.pointsOfInterest.append(pin)
                    
                    if let index = self.waypoints.indexOf({ $0.title! == pin.title! }) {
                        self.waypoints.removeAtIndex(index)
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
            ATAlertView.alertWithConfirmationForVenue(self, image: UIImage(named: "venue")!, title: annotation.title!!, text: "You are about to add this place as a waypoint.", action: "Add", callback: {
                
                let pin = annotation as! ATAnnotation
                pin.type = .Waypoint
                
                self.waypoints.append(pin)
                
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
    
    func geocodeWithQuery(query: String, type: ATAnnotation.ATAnnotationType, completion: ATAnnotation -> ()) {
        let options = ForwardGeocodeOptions(query: query)
        options.focalLocation = mapView.userLocation?.location
        options.autocompletesQuery = false
        
        geocoder.geocode(options: options) { (placemarks, attribution, error) in
            if error == nil {
                if let placemarks = placemarks {
                    if placemarks.isEmpty {
                        ATAlertView.alertWithTitle(self, type: ATAlertView.ATAlertViewType.Error, title: "Whoops", text: "We couldn't find an address matching your query") { return }
                    }
                    
                    guard let placemarkAddress = placemarks.first where placemarks.first != nil else {
                        return
                    }
                    
                    let pin = ATAnnotation(typeSelected: type)
                    pin.coordinate = placemarkAddress.location.coordinate
                    pin.title = placemarkAddress.name
                    pin.subtitle = placemarkAddress.qualifiedName
                    completion(pin)
                }
            }
        }
    }
    
    
    //    func reverseGeocode(location: CLLocation, completion: (address: String?) -> ()) {
    //        let options = ReverseGeocodeOptions(location: location)
    //
    //        geocoder.geocode(options: options) { (placemarks, attribution, error) in
    //            if error == nil {
    //                if let placemarks = placemarks {
    //                    completion(address: placemarks[0].name)
    //                }
    //            } else {
    //                print("Error reverse-geocoding: \(error)")
    //                completion(address: nil)
    //            }
    //        }
    //    }
    
    // MARK: - Foursquare API
    
    func addFoursquareAnnotations(completion: (count: Int) -> ()) {
        
        pointsOfInterest.removeAll()
        waypoints.removeAll()
        
        guard let origin = origin, destination = destination else {
            return
        }
        
        locationStore.origin = origin.coordinate
        locationStore.destination = destination.coordinate
        
        self.store.getDataWithCompletion {
            
            for location in self.store.foursquareData {
                let pin = ATAnnotation(typeSelected: .PointOfInterest)
                
                pin.coordinate = CLLocationCoordinate2D(latitude: location.placeLatitude, longitude: location.placeLongitude)
                pin.title = location.placeName
                pin.subtitle = location.placeAddress
                //pin.type = .PointOfInterest
                
                self.pointsOfInterest.append(pin)
            }
            
            completion(count: self.pointsOfInterest.count)
        }
    }
    
    // MARK: - Paths
    
    func assignOrigin(originPoint: ATAnnotation) {
        origin = originPoint
        mapView.addAnnotation(originPoint)
        mapView.setCenterCoordinate(originPoint.coordinate, animated: true)
        
        if destination != nil && origin != nil {
            drawRouteButton.enabled = true
        } else {
            drawRouteButton.enabled = false
        }
    }
    
    func assignDestination(destinationPoint: ATAnnotation) {
        destination = destinationPoint
        mapView.addAnnotation(destinationPoint)
        mapView.setCenterCoordinate(destinationPoint.coordinate, animated: true)
        
        if destination != nil && origin != nil {
            drawRouteButton.enabled = true
        } else {
            drawRouteButton.enabled = false
        }
    }
    
    func createPath(completion: (time: String) -> ()) {
        removeUnusedWaypoints()
        
        var waypoints: [Waypoint] = []
        
        for waypoint in self.waypoints {
            let waypoint = Waypoint(coordinate: waypoint.coordinate)
            waypoints.append(waypoint)
        }
        
        guard let origin = origin, let destination = destination else {
            return
        }
        
        let originWaypoint = Waypoint(coordinate: origin.coordinate)
        let destinationWaypoint = Waypoint(coordinate: destination.coordinate)
        
        waypoints.insert(originWaypoint, atIndex: 0)
        waypoints.append(destinationWaypoint)
        
        print("Waypoints (sorted)")
        for point in waypoints {
            print(point.coordinate)
        }
        
        // Directions
        
        let directions = Directions(accessToken: Keys.mapBoxToken)
        let options = RouteOptions(waypoints: waypoints, profileIdentifier: MBDirectionsProfileIdentifierWalking)
        options.includesSteps = true
        options.routeShapeResolution = .Full
        
        directions.calculateDirections(options: options) { (waypoints, routes, error) in
            guard error == nil else {
                print("Error getting directions: \(error!)")
                return
            }
            
            if let routes = routes {
                self.navigationRoutes = routes
            }
            
            if let route = routes?.first, let leg = route.legs.first {
                print("Route via \(leg)")
                
                self.navigationLegs = route.legs
                
                let distanceFormatter = NSLengthFormatter()
                let formattedDistance = distanceFormatter.stringFromMeters(route.distance)
                
                let travelTimeFormatter = NSDateComponentsFormatter()
                travelTimeFormatter.unitsStyle = .Short
                let formattedTravelTime = travelTimeFormatter.stringFromTimeInterval(route.expectedTravelTime)
                
                print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
                
                completion(time: formattedTravelTime!)
                
                if route.coordinateCount > 0 {
                    var routeCoordinates = route.coordinates!
                    self.routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
                    
                    if let routeLine = self.routeLine {
                        self.mapView.addAnnotation(routeLine)
                        self.mapView.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: UIEdgeInsetsZero, animated: true)
                    }
                }
            }
        }
    }
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        geocoder = Geocoder(accessToken: Keys.mapBoxToken)
        
        dropdownView = ATDropdownView(view: self.view)
        dropdownView.delegate = self
        
        delay(0.3) {
            self.dropdownView.show()
            self.dropdownDisplayed = true
        }
        
        currentStage = .Default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ATMapViewController {
    
    // MARK: - Location Related
    
    func sortWaypoints(waypoints: [Waypoint]) {
        var waypoints = waypoints
        if let origin = origin {
            let current = CLLocation(latitude: origin.coordinate.latitude, longitude: origin.coordinate.longitude)
            
            waypoints.sortInPlace { (loc1, loc2) -> Bool in
                let loc1 = CLLocation(latitude: loc1.coordinate.latitude, longitude: loc1.coordinate.longitude)
                let loc2 = CLLocation(latitude: loc2.coordinate.latitude, longitude: loc2.coordinate.longitude)
                
                return current.distanceFromLocation(loc1) < current.distanceFromLocation(loc2)
            }
        }
    }
    
    func coordinatesEqual(location: CLLocationCoordinate2D, other: CLLocationCoordinate2D) -> Bool {
        return location.latitude == other.latitude && location.longitude == other.longitude
    }
    
    //    func pinIsDuplicate(pin: MGLAnnotation) -> Bool {
    //        let coordinate = pin.coordinate
    //
    //        for waypoint in self.waypoints {
    //            if coordinatesEqual(waypoint.coordinate, other: coordinate) {
    //                return true
    //            }
    //        }
    //
    //        return false
    //    }
    
    func containsWaypoint(waypoint: ATAnnotation) -> Bool {
        if waypoints.contains({ $0.title! == waypoint.title! }) {
            return true
        }
        
        return false
    }
    
    // MARK: - Map Related
    
    func canCreatePath() -> Bool {
        return origin != nil && destination != nil
    }
    
    func clearMapView() {
        removeOriginAndDestination()
        removePath()
        removeUnusedWaypoints()
        removeWaypoints()
    }
    
    func removeOriginAndDestination() {
        guard let origin = origin, destination = destination else {
            return
        }
        mapView.removeAnnotations([origin, destination])
    }
    
    func removePath() {
        if let routeLine = routeLine {
            mapView.removeAnnotation(routeLine)
        }
    }
    
    func removeWaypoints() {
        mapView.removeAnnotations(waypoints)
        waypoints.removeAll()
    }
    
    func removeUnusedWaypoints() {
        mapView.removeAnnotations(pointsOfInterest)
        pointsOfInterest.removeAll()
    }
    
    // MARK: - Helpers
    
    func delay(delay: NSTimeInterval, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), block)
    }
}

extension UITabBarController {
    
    func setTabBarVisible(visible: Bool, animated: Bool) {
        if (tabBarIsVisible() == visible) {
            return
        }
        
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible ? -height : height)
        
        UIView.animateWithDuration(animated ? 0.3 : 0.0) {
            self.tabBar.frame = CGRectOffset(frame, 0, offsetY)
            self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height + offsetY)
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }
    }
    
    func tabBarIsVisible() -> Bool {
        return self.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)
    }
}
