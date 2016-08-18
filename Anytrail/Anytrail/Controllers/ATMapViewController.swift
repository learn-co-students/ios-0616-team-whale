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

    var onceToken: dispatch_once_t = 0

    let store = ApisDataStore.sharedInstance
    let locationStore = LocationDataStore.sharedInstance
    var geocoder: Geocoder!

    var gestureRecognizer: UILongPressGestureRecognizer! = nil

    var origin: ATAnnotation! = nil
    var destination: ATAnnotation! = nil
    var routeLine: MGLPolyline!

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
            locationStore.originString = location
            geocodeWithQuery(location, type: .Origin)
        }
    }

    func dropdownDidUpdateDestination(location: String) {
        if location.characters.count > 3 {
            locationStore.destinationString = location
            geocodeWithQuery(location, type: .Destination)
        }
    }

    func reshowDropdown(withView view: ATDropdownView.ATDropownViewType, hintText: String) {
        if !dropdownDisplayed {
            dropdownView.changeDropdownView(view)

            if view == .Label {
                dropdownView.updateHintLabel(hintText)
            }
            
            dropdownView.updateOriginTextField(locationStore.originString!)
            dropdownView.updateDestinationTextField(locationStore.destinationString!)
            
            dropdownView.show()

        } else {
            dropdownView.hide()

            delay(0.3, block: {
                self.dropdownView.changeDropdownView(view)

                if view == .Label {
                    self.dropdownView.updateHintLabel(hintText)
                }

                self.dropdownView.updateOriginTextField(self.locationStore.originString!)
                self.dropdownView.updateDestinationTextField(self.locationStore.destinationString!)
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

            // This will empty all arrays pertaining to data on the map
            // and ultimately wipe it clean. Retains origin/destination
            clearMapView()
        }
    }

    @IBAction func create() {
        if currentStage == .Default {
            createMode = true

            currentStage = .Waypoints

            UIView.animateWithDuration(0.3, animations: {
                self.dropdownBarButton.image = UIImage(named: "back-arrow")
                
                self.dropdownBarButton.enabled = false
                self.drawRouteButton.enabled = false
            })
            
            addFoursquareAnnotations({ (count) in
                self.reshowDropdown(withView: .Label, hintText: "Awesome! We found \(count) places to pass on your way.\nStart by selecting some!")
                self.dropdownBarButton.enabled = true
                self.drawRouteButton.enabled = true
            })

        } else if currentStage == .Waypoints {
            // Waypoints selected, sort and generate route
            // Change icon to GO
            
            if pins.count > 0 {
                currentStage = .Route
                createPath({ (time) in
                    self.reshowDropdown(withView: .Label, hintText: "Your walk will last about \(time).\nEnjoy your walk to \(self.destination.title!)!")
                })
                
            } else {
                ATAlertView.alertWithTitle(self, type: .Error, title: "Whoops", text: "Select at least one point to pass", callback: {
                    return
                })
            }
        }
    }

    // MARK: - Mapbox

    func mapView(mapView: MGLMapView, didUpdateUserLocation userLocation: MGLUserLocation?) {
        if let location = mapView.userLocation {
            dispatch_once(&onceToken) { () -> Void in
                mapView.setCenterCoordinate(location.coordinate, animated: true)
            }
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
                ATAlertView.alertWithConfirmationForVenue(self, image: UIImage(named: "venue")!, title: annotation.title!!, text: "You are about to remove this place as a waypoint.", action: "Remove", callback: {
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

            ATAlertView.alertWithConfirmationForVenue(self, image: UIImage(named: "venue")!, title: annotation.title!!, text: "You are about to add this place as a waypoint.", action: "Add", callback: {
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
                            print("THIS PIN THINKS IT'S DESTINATION: \(pin)")
                            self.assignDestination(pin)
                            return
                        }

                        if !self.pinIsDuplicate(pin) {
                            self.pins.append(pin)
                            self.mapView.addAnnotation(pin)

                        } else {
                            // Pin already exists (gesture recognizer spam issue)
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

    func addFoursquareAnnotations(completion: (count: Int) -> ()) {
        pointsOfInterest.removeAll()
        locationStore.origin = origin.coordinate
        locationStore.destination = destination.coordinate

        locationStore.settingRectangleForFoursquare()

        store.getDataWithCompletion {
            for location in self.store.foursquareData {
                let pin = ATAnnotation()

                pin.coordinate = CLLocationCoordinate2D(latitude: location.placeLatitude, longitude: location.placeLongitude)
                pin.title = location.placeName
                pin.subtitle = location.placeAddress
                pin.type = .PointOfInterest

                self.pointsOfInterest.append(pin)
                self.mapView.addAnnotation(pin)
            }

            completion(count: self.pointsOfInterest.count)
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

    func createPath(completion: (time: String) -> ()) {
        removeUnusedWaypoints()

        var waypoints: [Waypoint] = []

        for pin in pins {
            let waypoint = Waypoint(coordinate: pin.coordinate)
            waypoints.append(waypoint)
        }
        
        print("Waypoints (unsorted)")
        for point in waypoints {
            print(point.coordinate)
        }

        sortWaypoints(waypoints)

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
        let options = RouteOptionsV4(waypoints: waypoints, profileIdentifier: MBDirectionsProfileIdentifierWalking)
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
                
                completion(time: formattedTravelTime!)

                for step in leg.steps {
                    // print("\(step.instructions)")
                    let formattedDistance = distanceFormatter.stringFromMeters(step.distance)
                    print("— \(formattedDistance) —")
                }

                if route.coordinateCount > 0 {
                    var routeCoordinates = route.coordinates!
                    self.routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
                    
                    self.mapView.addAnnotation(self.routeLine)
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

        // TODO: Remove. Only for fast debugging and testing
        // dropdownDidUpdateOrigin("11 Broadway New York, NY")
        // dropdownDidUpdateDestination("Alphabet City")

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
    
    // MARK: - Location Related
    
    func sortWaypoints(waypoints: [Waypoint]) {
        var waypoints = waypoints
        let current = CLLocation(latitude: origin.coordinate.latitude, longitude: origin.coordinate.longitude)

        waypoints.sortInPlace { (loc1, loc2) -> Bool in
            let loc1 = CLLocation(latitude: loc1.coordinate.latitude, longitude: loc1.coordinate.longitude)
            let loc2 = CLLocation(latitude: loc2.coordinate.latitude, longitude: loc2.coordinate.longitude)
            
            return current.distanceFromLocation(loc1) < current.distanceFromLocation(loc2)
        }
    }

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
    
    // MARK: - Map Related

    func canCreatePath() -> Bool {
        return origin != nil && destination != nil
    }
    
    func clearMapView() {
        removeWaypoints()
        removeUnusedWaypoints()
        removePath()
    }
    
    func removePath() {
        if routeLine != nil {
            mapView.removeAnnotation(routeLine)
            routeLine = nil
        }
    }

    func removeWaypoints() {
        mapView.removeAnnotations(pins)
        pins.removeAll()
    }

    func removeUnusedWaypoints() {
        mapView.removeAnnotations(pointsOfInterest)
        pointsOfInterest.removeAll()
    }

    func delay(delay: NSTimeInterval, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), block)
    }
}
