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
    
    func addFoursquareAnnotations() {
        
        for location in store.foursquareData {
            let pin = MGLPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: location.placeLatitude, longitude: location.placeLongitude)
            pin.title = location.placeName
            
            pin.subtitle = location.placeAddress
            mapView.addAnnotation(pin)
            
        }
        
    }
    
    func addTrailsAnnotations() {
        for trail in store.mashapeData {
            if trail.isHiking == true {
                let pin = MGLPointAnnotation()
                pin.coordinate = CLLocationCoordinate2D(latitude: trail.placeLatitude, longitude: trail.placeLongitude)
                pin.title = trail.placeName
//                pin.subtitle = trail.isHiking.description
                mapView.addAnnotation(pin)
            }
            
        }
    }
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        MashapeAPIClient.getTrails { (data) in
            
        }
    
        FoursquareAPIClient.getQueryForSearchLandmarks { (data) in
            
        }
        
        ApisDataStore.sharedInstance.getTrailsWithCompletion {
            self.addTrailsAnnotations()
        }
        
        ApisDataStore.sharedInstance.getDataWithCompletion {
//            self.addFoursquareAnnotations()
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
