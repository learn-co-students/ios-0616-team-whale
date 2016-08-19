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

var reachability: Reachability?
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    //Setup userDefaults
    static let userDefaultWalkData = NSUserDefaults.standardUserDefaults()
    static var activeWorkout = false
    
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
        
        //Setup work if was active when app was terminated
        AppDelegate.activeWorkout = AppDelegate.userDefaultWalkData.valueForKey("workoutActive") as? Bool ?? false
        if AppDelegate.activeWorkout {
            let startDate = AppDelegate.userDefaultWalkData.valueForKey("walkStartDate") as? NSDate
            let continueDate = NSDate()
            
            if let startDate = startDate {
                WalkTrackerViewController.walkTrackerSession = WalkTracker.init(startDate: startDate, continueDate: continueDate)
            }
        }
        return true
    }
    
    func reachabilitySetup() {
        
        // Set up reachability class
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch let error as NSError {
            print("ERROR: Unable to start reachability \(error.localizedDescription)")
        }
        
        // Add observer to app delegate
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reachabilityChanged)
            ,name: ReachabilityChangedNotification,object: reachability)
        
        // Tell reachability class to start notifications
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
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        AppDelegate.userDefaultWalkData.setValue(WalkTrackerViewController.walkTrackerSession.walkStartDate, forKey: "walkStartDate")
        AppDelegate.userDefaultWalkData.setValue(AppDelegate.activeWorkout, forKey: "workoutActive")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        print("\n\nApplication WILL ENTER FOREGROUND\n\n")
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        if AppDelegate.activeWorkout {
            let startDate = AppDelegate.userDefaultWalkData.valueForKey("walkStartDate") as? NSDate
            let continueDate = NSDate()
            
            if let startDate = startDate {
                WalkTrackerViewController.walkTrackerSession = WalkTracker.init(startDate: startDate, continueDate: continueDate)
                WalkTrackerViewController.walkTrackerSession.startWalk()
            }
        }
        
        
        print("\n\nApplication DID BECOME ACTIVE\n\n")
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        AppDelegate.userDefaultWalkData.setValue(WalkTrackerViewController.walkTrackerSession.walkStartDate, forKey: "walkStartDate")
        AppDelegate.userDefaultWalkData.setValue(AppDelegate.activeWorkout, forKey: "workoutActive")
        WalkTrackerViewController.walkTrackerSession.walkTimer.invalidate()
    }
}
