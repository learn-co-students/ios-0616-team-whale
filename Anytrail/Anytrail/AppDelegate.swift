//
//  AppDelegate.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import FBSDKLoginKit
import Firebase
import Mapbox
import UIKit
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var reachability: Reachability?
    var window: UIWindow?
    var userDefaults: NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        reachabilitySetup()
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        UINavigationBar.appearance().translucent = false
        
        UITabBar.appearance().translucent = false
        
        
        // Set Mapbox token
        MGLAccountManager.setAccessToken(Keys.mapBoxToken)
        
        // Setup Firebase
        FIRApp.configure()
        
        WalkTracker.sharedInstance.activeWalk = userDefaults.valueForKey("workoutActive") as? Bool ?? false
        if WalkTracker.sharedInstance.activeWalk == true {
            let startDate = userDefaults.valueForKey("walkStartDate") as? NSDate
            let continueDate = NSDate()
            
            if let startDate = startDate {
                WalkTracker.sharedInstance.continueSession(startDate, continueDate: continueDate)
            }
        }
        return true
    }
    
    func reachabilitySetup() {
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch let error as NSError {
            print("ERROR: Unable to start reachability \(error.localizedDescription)")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reachabilityChanged)
            ,name: ReachabilityChangedNotification,object: reachability)
        
        do {
            try reachability?.startNotifier()
        } catch let error as NSError {
            print("ERROR: couldn't start notifier \(error.localizedDescription)")
        }
    }
    
    func reachabilityChanged() {
        guard let reachability = reachability else { return }
        
        let status = InternetStatus.shared
        
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                status.hasInternet = true
                print("Reachable via WiFi")
            } else {
                status.hasInternet = true
                print("Reachable via Cellular")
            }
        } else {
            status.hasInternet = false
            print("Network not reachable")
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        userDefaults.setValue(WalkTracker.sharedInstance.walkStartDate, forKey: "walkStartDate")
        userDefaults.setValue(WalkTracker.sharedInstance.activeWalk, forKey: "workoutActive")
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        if WalkTracker.sharedInstance.activeWalk == true {
            let startDate = userDefaults.valueForKey("walkStartDate") as? NSDate
            let continueDate = NSDate()
            
            if let startDate = startDate {
                WalkTracker.sharedInstance.continueSession(startDate, continueDate: continueDate)
            }
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        userDefaults.setValue(WalkTracker.sharedInstance.walkStartDate, forKey: "walkStartDate")
        userDefaults.setValue(WalkTracker.sharedInstance.activeWalk, forKey: "workoutActive")
    }
}
