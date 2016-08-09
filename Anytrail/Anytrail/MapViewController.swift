//
//  MapViewController.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Mapbox
import UIKit

class MapViewController: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet var mapView: MGLMapView!
    
    let store = ApisDataStore.sharedInstance

    
    // MARK: - Mapbox
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func addAnnotation() {
        
        for location in store.foursquareData {
            let pin = MGLPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: location.placeLatitude, longitude: location.placeLongitude)
            pin.title = location.placeName
            
            pin.subtitle = location.placeAddress
            mapView.addAnnotation(pin)
            
        }
//        
//        for trail in store.mashapeData {
//            let pin = MGLPointAnnotation()
//            pin.coordinate = CLLocationCoordinate2D(latitude: trail.placeLatitude, longitude: trail.placeLongitude)
//            pin.title = trail.placeName
//            
//            pin.subtitle = trail.isHiking.description
//            mapView.addAnnotation(pin)
//        }
////        let pin = MGLPointAnnotation()
//        pin.coordinate = CLLocationCoordinate2D(latitude: 40.70528, longitude: -74.014025)
//        pin.title = "Flatiron School"
//        pin.subtitle = "Bowling Green Offices"
//        
//        mapView.addAnnotation(pin)
//        
//        let testPin = MGLPointAnnotation()
//        let object = store.data[0]
//        testPin.coordinate = CLLocationCoordinate2D(latitude: object.placeLatitude, longitude: object.placeLongitude)
//        pin.title = object.placeName
//        mapView.addAnnotation(testPin)
    }
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        MashapeAPIClient.getTrails { (data) in
            
        }
        ApisDataStore.sharedInstance.getTrailsWithCompletion { 
            self.addAnnotation()
        }
        
        FoursquareAPIClient.getQueryForSearchLandmarks { (data) in
            
        }
        
        ApisDataStore.sharedInstance.getDataWithCompletion {
            self.addAnnotation()
        }
        
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func userProfileTapped(sender: AnyObject) {
        presentUserDataView()
    }
    
    func presentUserDataView() {
        let userHealthDataView = HealthDataViewController()
        presentViewController(userHealthDataView, animated: true) {
            print("Health View Presented")
        }
    }
}
