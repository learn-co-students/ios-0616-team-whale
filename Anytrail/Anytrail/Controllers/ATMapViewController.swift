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
import ReachabilitySwift

import UIKit

class ATMapViewController: UIViewController, MGLMapViewDelegate, ATDropdownViewDelegate {
    
    @IBOutlet var mapView: MGLMapView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dropdownBarButton: UIBarButtonItem!
    @IBOutlet weak var drawRouteButton: UIBarButtonItem!
    
    var geocoder = Geocoder(accessToken: Keys.mapBoxToken)
    
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
    
    enum ATCurrentStage: Int {
        case Default
        case Waypoints
        case Route
    }
    
    var currentStage: ATCurrentStage?
    
    // MARK: - Origin/Destination Annotations
    
    func dropdownDidUpdateOrigin(location: String?) {
        guard let locationString = location else {
            return
        }
        geocodeWithQuery(locationString, type: .Origin) { originGeocoded in
            self.assignOrigin(originGeocoded)
        }
    }
    
    func dropdownDidUpdateDestination(location: String?) {
        guard let locationString = location else {
            return
        }
        geocodeWithQuery(locationString, type: .Destination) { destinationGeocoded in
            self.assignDestination(destinationGeocoded)
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
            configureDropdownButtonForState(dropdownDisplayed)
        case .Waypoints:
            currentStage = .Default
            reshowDropdown(withView: .Default, hintText: "")
            UIView.animateWithDuration(0.3) {
                self.dropdownBarButton.image = UIImage(named: "dropdown")
            }
            drawRouteButton.enabled = false
            clearMapView()
        case .Route:
            clearMapView()
            reshowDropdown(withView: .Default, hintText: "")
        }
    }
    
    func configureDropdownButtonForState(isDisplaying: Bool) {
        let buttonImage: UIImage?
        if isDisplaying {
            buttonImage = UIImage(named: "dropdown-up")
            dropdownView.hide()
        } else {
            buttonImage = UIImage(named: "dropdown")
            dropdownView.show()
        }
        dropdownBarButton.image = buttonImage
        dropdownDisplayed = !isDisplaying
    }
    
    @IBAction func create() {
        guard let currentStage = currentStage else {
            return
        }
        
        switch currentStage {
        case .Default:
            setToWaypoints()
        case .Waypoints:
            setToRoute()
        case .Route:
            setToWaypoints()
        }
    }
    
    func setToWaypoints() {
        createMode = true
        currentStage = .Waypoints
        getWaypoints()
        UIView.animateWithDuration(0.3) {
            self.dropdownBarButton.image = UIImage(named: "back-arrow")
        }
    }
    
    
    func setToRoute() {
        if waypoints.count > 0 {
            currentStage = .Route
            mapView.removeAnnotations(pointsOfInterest)
            createPath() { time in
                self.reshowDropdown(withView: .Label, hintText: "Your walk will take about \(time).\nEnjoy your walk to \(self.destination?.title ?? "")!")
            }
        } else {
            ATAlertView.alertWithTitle(self, type: .Error, title: "Whoops", text: "Select at least one point to pass") { }
        }
    }
    
    func getWaypoints() {
        addFoursquareAnnotations() { count in
            dispatch_async(dispatch_get_main_queue()) {
                for pin in self.pointsOfInterest {
                    self.mapView.addAnnotation(pin)
                }
            }
        }
    }
    
    func checkOriginAndDestinationAssigned() {
        if destination != nil && origin != nil {
            drawRouteButton.enabled = true
        }
    }
    
    
    @IBAction func navigateTapped(sender: AnyObject) {
//        UIApplication.sharedApplication().canOpenURL(
//            NSURL(string: "comgooglemaps://")!)
//        
//        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
//            UIApplication.sharedApplication().openURL(NSURL(string:
//                "comgooglemaps://?saddr=2025+Garcia+Ave,+Mountain+View,+CA,+USA&daddr=Google,+1600+Amphitheatre+Parkway,+Mountain+View,+CA,+United+States&waypoints=+Charlestown,+MA|Lexington,+MA&key&center=37.423725,-122.0877&directionsmode=walking&zoom=17")!)
//        } else {
//            print("Can't use comgooglemaps://");
//        }
//        let navigationOriginDestinationString = waypoints
//        waypoints.removeFirst()
        
//        var waypointString = ""
//        
//        for pin in waypoints {
//            waypointString = waypointString + "\(pin.coordinate.latitude)," + "\(pin.coordinate.longitude)&"
//        }
//        
//        print(waypointString)
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
            print("Something happened when selected")
        }
    }
    
    func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        guard let annotationSelected = annotation as? ATAnnotation else {
            return nil
        }
        
        switch annotationSelected.type {
        case .Waypoint:
            let removeButton = UIButton(type: .System)
            let myAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(22, weight: UIFontWeightLight)]
            let buttonIcon = NSAttributedString(string: "ⓧ", attributes: myAttributes)
            removeButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
            removeButton.setAttributedTitle(buttonIcon, forState: .Normal)
            removeButton.tintColor = ATConstants.Colors.RED
            return removeButton
        case .PointOfInterest:
            let addButton = UIButton(type: .ContactAdd)
            addButton.tintColor = ATConstants.Colors.GREEN
            return addButton
        default:
            return nil
        }
    }
    
    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // Hide the callout view.
        mapView.deselectAnnotation(annotation, animated: false)
        
        guard let selectedAnnotation = annotation as? ATAnnotation else {
            return
        }
        
        if createMode && currentStage == .Waypoints {
            
            if containsWaypoint(selectedAnnotation) {
                if let index = waypoints.indexOf({ $0.title! == selectedAnnotation.title! }) {
                    waypoints.removeAtIndex(index)
                }
                selectedAnnotation.type = .PointOfInterest
                pointsOfInterest.append(selectedAnnotation)
                let annotationView = mapView.viewForAnnotation(annotation)
                annotationView?.backgroundColor = selectedAnnotation.backgroundColor
            } else {
                if let index = self.pointsOfInterest.indexOf(selectedAnnotation) {
                    self.pointsOfInterest.removeAtIndex(index)
                }
                selectedAnnotation.type = .Waypoint
                waypoints.append(selectedAnnotation)
                let annotationView = mapView.viewForAnnotation(annotation)
                annotationView?.backgroundColor = selectedAnnotation.backgroundColor
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
            annotationView?.frame = CGRectMake(0, 0, 25, 25)
        }
        annotationView?.backgroundColor = (annotation as? ATAnnotation)?.backgroundColor
        return annotationView
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
    
    // MARK: - Foursquare API
    
    func addFoursquareAnnotations(completion: (count: Int) -> ()) {
        guard let origin = origin, destination = destination else {
            completion(count: 0)
            return
        }
        
        pointsOfInterest.removeAll()
        waypoints.removeAll()
        
        LocationDataStore.sharedInstance.origin = CLLocation(latitude: origin.coordinate.latitude, longitude:  origin.coordinate.longitude)
        LocationDataStore.sharedInstance.destination = CLLocation(latitude: destination.coordinate.latitude, longitude:  destination.coordinate.longitude)
        
        ApisDataStore.sharedInstance.pointOfInterestEpicenterQuery { success in
            if success {
                for location in ApisDataStore.sharedInstance.foursquareData {
                    let pin = ATAnnotation(typeSelected: .PointOfInterest)
                    
                    pin.coordinate = CLLocationCoordinate2D(latitude: location.placeLatitude, longitude: location.placeLongitude)
                    pin.title = location.placeName
                    pin.subtitle = location.placeAddress
                    self.pointsOfInterest.append(pin)}
            } else {
                ATAlertView.alertNetworkLoss(self, callback: {})
            }
            completion(count: self.pointsOfInterest.count)
        }
    }
    
    // MARK: - Paths
    
    func assignOrigin(originPoint: ATAnnotation) {
        if let origin = origin {
            mapView.removeAnnotation(origin)
        }
        
        origin = originPoint
        mapView.addAnnotation(originPoint)
        mapView.setCenterCoordinate(originPoint.coordinate, animated: true)
        checkOriginAndDestinationAssigned()
    }
    
    func assignDestination(destinationPoint: ATAnnotation) {
        if let destination = destination {
            mapView.removeAnnotation(destination)
        }
        
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
        if !InternetStatus.shared.hasInternet {
            print("\n\nthere is no internet connection\n\n")
            ATAlertView.alertNetworkLoss(self, callback: {})
        }
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ATMapViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    func reachabilityChanged(notification: NSNotification) {
        guard let reachability = notification.object as? Reachability else {return}
        if !reachability.isReachable() {
            ATAlertView.alertNetworkLoss(self, callback: {})
        }
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
