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
    
    var geocoder = Geocoder(accessToken: Keys.mapBoxToken)
    
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
    
    var currentStage: ATCurrentStage?
    
    // MARK: - ATDropdownView
    
    func dropdownDidUpdateOrigin(location: String) {
        if originString != location {
            originString = location
            if let origin = origin {
                mapView.removeAnnotation(origin)
            }
            geocodeWithQuery(location, type: .Origin) { originAnnotation in
                self.assignOrigin(originAnnotation)
            }
        }
    }
    
    func dropdownDidUpdateDestination(location: String) {
        if destinationString != location {
            destinationString = location
            if let destination = destination {
                mapView.removeAnnotation(destination)
            }
            geocodeWithQuery(location, type: .Destination) { destinationAnnotation in
                self.assignDestination(destinationAnnotation)
            }
        }
    }
    
    func reshowDropdown(withView view: ATDropdownView.ATDropownViewType, hintText: String) {
        dropdownView.hide()
        dropdownView.changeDropdownView(view)
        
        if view == .Label {
            dropdownView.updateHintLabel(hintText)
        }
        
        delay(1.0) {
            self.dropdownView.show()
            self.dropdownDisplayed = true
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func dropdown() {
        guard let currentStageOfDropdown = currentStage else {
            return
        }
        
        switch currentStageOfDropdown {
        case .Default:
            if dropdownDisplayed {
                dropdownBarButton.image = UIImage(named: "dropdown")
                
                dropdownView.hide()
                dropdownDisplayed = false
            } else {
                dropdownBarButton.image = UIImage(named: "dropdown-up")
                
                dropdownView.show()
                dropdownDisplayed = true
            }
        case .Waypoints:
            currentStage = .Default
            reshowDropdown(withView: .Default, hintText: "")
            UIView.animateWithDuration(0.3) {
                self.dropdownBarButton.image = UIImage(named: "dropdown")
            }
            clearMapView()
        default:
            print("Encountered an unexpected button state")
        }
    }
    
    func setToRoutes() {
        if waypoints.count > 0 {
            currentStage = .Route
            createPath() { time in
                self.reshowDropdown(withView: .Label, hintText: "Your walk will take about \(time).\nEnjoy your walk to \(self.destination?.title)!")
            }
            
        } else {
            ATAlertView.alertWithTitle(self, type: .Error, title: "Whoops", text: "Select at least one point to pass") { }
        }
    }
    
    @IBAction func create() {
        guard let currentStage = currentStage else {
            return
        }
        
        switch currentStage {
        case .Route:
            print("Routes")
        case .Waypoints:
            setToRoutes()
        default:
            setToDefaultToWaypoints()
        }
    }
    
    func setToDefaultToWaypoints() {
        getWaypoints()
        
        //createMode = true
        currentStage = .Waypoints
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.3) {
                self.dropdownBarButton.image = UIImage(named: "back-arrow")
            }
        }
    }
    
    func getWaypoints() {
        addFoursquareAnnotations() { count in
            dispatch_async(dispatch_get_main_queue()) {
                for pin in self.pointsOfInterest {
                    self.mapView.addAnnotation(pin)
                }
            }
            //            self.reshowDropdown(withView: .Label, hintText: "Awesome! We found \(count) places to visit on your way.\nStart by selecting some!")
        }
    }
    
    func checkOriginAndDestinationAssigned() {
        if destination != nil && origin != nil {
            drawRouteButton.enabled = true
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
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor.darkGrayColor()
    }
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        guard let selectedAnnotation = annotation as? ATAnnotation else {
            return
        }
        
        guard let origin = origin, let destination = destination else {
            return
        }
        
        switch selectedAnnotation.type {
        case .Origin:
            ATAlertView.alertWithTitle(self, type: .Origin, title: origin.title!, text: "This is your origin.") {
                mapView.deselectAnnotation(annotation, animated: true)
            }
        case .Destination:
            ATAlertView.alertWithTitle(self, type: .Error, title: destination.title!, text: "This is your destination.") {
                mapView.deselectAnnotation(annotation, animated: true)
            }
        default:
            if createMode && currentStage == .Waypoints {
                
                let pin = selectedAnnotation
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
                } else {
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
            }
        }
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
        if annotationView == nil {
            annotationView = ATAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView?.frame = CGRectMake(0, 0, 30, 30)
        }
        annotationView?.backgroundColor = (annotation as? ATAnnotation)?.backgroundColor
        return annotationView
    }


    
    
//    func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {
//        guard annotation is MGLPointAnnotation else {
//            return nil
//        }
//        
//        let reuseIdentifier = "AnnotationId"
//        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
//        
//        if annotationView == nil {
//            
//            //            let extantPins = mapView.annotations?.filter{ $0.coordinate.latitude == annotation.coordinate.latitude && $0.coordinate.longitude == annotation.coordinate.longitude} ?? []
//            guard let pin = annotation as? ATAnnotation else {
//                return nil
//            }
//            
//            annotationView = ATAnnotationView(reuseIdentifier: reuseIdentifier)
//            annotationView?.frame = CGRectMake(0, 0, 25, 25)
//            annotationView?.backgroundColor = pin.backgroundColor
//        }
//        
//        return annotationView
//    }
    
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
    
    // MARK: - Foursquare API
    
    func addFoursquareAnnotations(completion: (count: Int) -> ()) {
        
        pointsOfInterest.removeAll()
        waypoints.removeAll()
        
        guard let origin = origin, destination = destination else {
            return
        }
        
        LocationDataStore.sharedInstance.origin = origin.coordinate
        LocationDataStore.sharedInstance.destination = destination.coordinate
        
        ApisDataStore.sharedInstance.getDataWithCompletion {
            
            for location in ApisDataStore.sharedInstance.foursquareData {
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
        checkOriginAndDestinationAssigned()
    }
    
    func assignDestination(destinationPoint: ATAnnotation) {
        destination = destinationPoint
        mapView.addAnnotation(destinationPoint)
        mapView.setCenterCoordinate(destinationPoint.coordinate, animated: true)
        checkOriginAndDestinationAssigned()
    }
    
    func createPath(completion: (time: String) -> ()) {
        //removeUnusedWaypoints()
        
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
        drawRouteButton.enabled = false
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
    
    func pinIsDuplicate(pin: MGLAnnotation) -> Bool {
        let coordinate = pin.coordinate
        
        for waypoint in self.waypoints {
            if coordinatesEqual(waypoint.coordinate, other: coordinate) {
                return true
            }
        }
        
        return false
    }
    
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
        if let annotationsToRemove = mapView.annotations {
            mapView.removeAnnotations(annotationsToRemove)
        }
        origin = nil
        destination = nil
        
        removePath()
        removeUnusedWaypoints()
        removeWaypoints()
    }
    
    
    func removePath() {
        if let routeLine = routeLine {
            mapView.removeAnnotation(routeLine)
        }
        routeLine = nil
    }
    
    func removeWaypoints() {
        waypoints.removeAll()
    }
    
    func removeUnusedWaypoints() {
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
