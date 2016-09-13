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
import TGLParallaxCarousel
import Firebase

import UIKit

class ATMapViewController: UIViewController, MGLMapViewDelegate, ATDropdownViewDelegate {
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var carouselView: TGLParallaxCarousel!
    @IBOutlet var mapView: MGLMapView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dropdownBarButton: UIBarButtonItem!
    @IBOutlet weak var drawRouteButton: UIBarButtonItem!
    
    let kit = AnytrailKit.sharedInstance
    
    var geocoder = Geocoder(accessToken: Keys.mapBoxToken)
    
    var origin: ATAnnotation?
    var destination: ATAnnotation?
    var routeLine: MGLPolyline?
    var pathPin: ATAnnotation?
    
    var createMode = false
    var waypoints: [ATAnnotation] = []
    var pointsOfInterest: [ATAnnotation] = []
    var foursquareDataResponse: [FoursquareData] = []
    
    var dropdownView: ATDropdownView!
    var dropdownDisplayed = false
    var navigationRoutes: [Route] = []
    var navigationLegs: [RouteLeg] = []
    var numberOfSteps: Int = 0
    
    var directionArray : [(RouteLeg, RouteStep, [CLLocationCoordinate2D]?)] = []
    var workOutTimer = NSTimer()
    
    var foursquareDataSource: LocationDataStore?
    
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
    
    func dropdownDidStartRoute() {
        WalkTracker.sharedInstance.startWalk()
        workOutTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateLabels(_:)), userInfo: nil, repeats: true)
        workOutTimer.fire()
        dropdownBarButton.enabled = false
    }
    
    func dropdownDidEndRoute() {
        dropdownView.updateActivityDistanceLabel("0.0")
        dropdownView.updateActivityTimeLabel("0:0:0")
        
        workOutTimer.invalidate()
        workOutTimer = NSTimer()
        
        dropdownBarButton.enabled = true
        
        WalkTracker.sharedInstance.stopWalk { saveResult in
            if saveResult {
                dispatch_async(dispatch_get_main_queue()) {
                    ATAlertView.alertWithTitle(self, type: ATAlertView.ATAlertViewType.Success, title: "Saved", text: "Your workout session was saved to HealthKit.") {}
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    ATAlertView.alertWithTitle(self, type: ATAlertView.ATAlertViewType.Error, title: "Error", text: "There was an error trying to save your workout session to HealthKit.") {}
                }
            }
        }
    }
    
    func updateLabels(timer: NSTimer) {
        let timePassed = secondsToHoursMinutesSeconds(Int(WalkTracker.sharedInstance.currentWalkTime))
        let distanceTravel = round((WalkTracker.sharedInstance.walkDistance / 1609.344) * 100) / 100
        
        dropdownView.updateActivityTimeLabel("\(timePassed.0):\(timePassed.1):\(timePassed.2)")
        dropdownView.updateActivityDistanceLabel("\(distanceTravel) miles")
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func reshowDropdown(withView view: ATDropdownView.ATDropownViewType, hintText: String) {
        dropdownView.hide()
        self.dropdownView.changeDropdownView(view)
        
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
            resetToDefaultStage()
        case .Route:
            currentStage = .Default
            clearMapView()
            configureDropdownButtonForState(dropdownDisplayed)
            reshowDropdown(withView: .Default, hintText: "")
            UIView.animateWithDuration(0.3) {
                self.dropdownBarButton.image = UIImage(named: "dropdown")
            }
            drawRouteButton.enabled = false
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
            break
        }
    }
    
    func resetToDefaultStage() {
        currentStage = .Default
        reshowDropdown(withView: .Default, hintText: "")
        UIView.animateWithDuration(0.3) {
            self.dropdownBarButton.image = UIImage(named: "dropdown")
        }
        drawRouteButton.enabled = false
        clearMapView()
    }
    
    func setToWaypoints() {
        createMode = true
        currentStage = .Waypoints
        dropdownView.hide()
        
        disableControlsForBuffer(true)
        getWaypoints()
        
        UIView.animateWithDuration(0.3) {
            self.dropdownBarButton.image = UIImage(named: "cancel")
        }
    }
    
    func getWaypoints() {
        self.loadingSpinner.startAnimating()
        addFoursquareAnnotations() { count in
            dispatch_async(dispatch_get_main_queue()) {
                self.loadingSpinner.stopAnimating()
                self.disableControlsForBuffer(false)
                
                if self.pointsOfInterest.isEmpty {
                    ATAlertView.alertWithTitle(self, type: .Error, title: "Whoops", text: "There were no points of interest found. Please try a different set of addresses.") {
                        self.resetToDefaultStage()
                    }
                } else {
                    for pin in self.pointsOfInterest {
                        self.mapView.addAnnotation(pin)
                    }
                    ATAlertView.alertWithTitle(self, type: .Success, title: "Great", text: "Please select some points of interest to add to your route.") { }
                }
            }
        }
    }
    
    func setToRoute() {
        if waypoints.count > 0 {
            mapView.scrollEnabled = false
            currentStage = .Route
            mapView.removeAnnotations(pointsOfInterest)
            createPath() { time in
                ATAlertView.alertWithTitle(self, type: .Success, title: "Path Saved", text: "Estimated Time:\n \(time).\nEnjoy your walk!") {
                    self.dropdownView.changeDropdownView(.Activity)
                    self.dropdownView.show()
                    self.drawRouteButton.enabled = false
                }
            }
        } else {
            ATAlertView.alertWithTitle(self, type: .Error, title: "Whoops", text: "Select at least one point to pass") { }
        }
    }
    
    func checkOriginAndDestinationAssigned() {
        if destination != nil && origin != nil {
            delay(1.0) {
                self.setToWaypoints()
            }
        }
    }
    
    func disableControlsForBuffer(disable: Bool) {
        dropdownBarButton.enabled = !disable
        drawRouteButton.enabled = !disable
        
        dropdownView.userInteractionEnabled = !disable
    }
    
    func giveScrollerPages()->Int{
        var count = 0
        for leg in navigationLegs{
            for _ in leg.steps{
                count += 1
            }
        }
        return count
    }
    
    func directionsArray(){
        for leg in navigationLegs{
            for step in leg.steps{
                directionArray.append((leg, step, step.coordinates))
            }
        }
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor.darkGrayColor()
    }
    
    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 4
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
            break
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
        
        let originLocation = CLLocation(latitude: origin.coordinate.latitude, longitude: origin.coordinate.longitude)
        let destinationLocation = CLLocation(latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude)
        foursquareDataSource = LocationDataStore(origin: originLocation, destination: destinationLocation)
        
        guard let foursquareDataSource = foursquareDataSource else {
            return
        }
        
        let centerPointLocation = foursquareDataSource.midpointCoordinates()
        
        foursquareDataSource.fetchLocationsFromFoursquareWithCompletion(centerPointLocation) { success in
            if success {
                for location in foursquareDataSource.foursquareData {
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
        var waypoints: [Waypoint] = []
        
        for waypoint in self.waypoints {
            let waypoint = Waypoint(coordinate: waypoint.coordinate)
            waypoints.append(waypoint)
        }
        
        sortWaypoints(waypoints)
        
        guard let origin = origin, let destination = destination else {
            return
        }
        
        let originWaypoint = Waypoint(coordinate: origin.coordinate)
        let destinationWaypoint = Waypoint(coordinate: destination.coordinate)
        
        waypoints.insert(originWaypoint, atIndex: 0)
        waypoints.append(destinationWaypoint)
        
        
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
            
            if let route = routes?.first {
                self.navigationLegs = route.legs
                self.carouselView.type = .Normal
                self.carouselView.hidden = false
                let travelTimeFormatter = NSDateComponentsFormatter()
                travelTimeFormatter.unitsStyle = .Short
                let formattedTravelTime = travelTimeFormatter.stringFromTimeInterval(route.expectedTravelTime)
                completion(time: formattedTravelTime!)
                
                // TODO: Remove testing data stuff
                // Call this function when user saves path
                self.kit.savePath(waypoints!, duration: formattedTravelTime!)
                
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
        carouselView.delegate = self
        carouselView.datasource = self
        carouselView.reloadInputViews()
        carouselView.bounceMargin = 1.0
        carouselView.itemMargin = 30.0
        carouselView.hidden = true
        pageControl.hidden = true
        self.loadingSpinner.color = UIColor.darkGrayColor()
        self.loadingSpinner.hidesWhenStopped = true
        
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
        carouselView.hidden = true
        origin = nil
        destination = nil
        directionArray = []
        navigationLegs = []
        navigationRoutes = []
        carouselView.carouselItems = []
        numberOfSteps = 0
        mapView.scrollEnabled = true
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

extension ATMapViewController: TGLParallaxCarouselDatasource {
    func numberOfItemsInCarousel(carousel: TGLParallaxCarousel) -> Int {
        
        return self.giveScrollerPages()
    }
    
    func viewForItemAtIndex(index: Int, carousel: TGLParallaxCarousel) -> TGLParallaxCarouselItem {
        directionsArray()
        let instruction = directionArray[index].1.instructions
        let directView = DirectionView(frame: CGRectMake(carousel.bounds.minX, carousel.bounds.minY, carousel.bounds.size.width, carousel.bounds.size.height * 0.35), leg: "\(directionArray[index].0)", step: "\(instruction)")
        return directView
    }
    
}

extension ATMapViewController: TGLParallaxCarouselDelegate {
    override func viewDidAppear(animated: Bool) {
        self.pageControl.hidden = true
    }
    
    func didTapOnItemAtIndex(index: Int, carousel: TGLParallaxCarousel) {
        
    }
    
    func didMovetoPageAtIndex(index: Int) {
        
        if let coordinatesInArray = directionArray[index].2{
            
            
            if let first = coordinatesInArray.first{
                mapView.setCenterCoordinate(first, zoomLevel: 15, animated: true)
            }
        }
    }
}