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
        self.reachabilitySetup()
        
        //        do {
        //            print("BEGIN inside appdelegate")
        //            reachability = try Reachability.reachabilityForInternetConnection()
        //            print("AFTER inside appdelegate")
        //            //try reachability?.startNotifier()
        //        } catch let error as NSError {
        //            print("Unable to start reachability \(error.localizedDescription)")
        //            return false
        //        }
        //        do {
        //            try reachability?.startNotifier()
        //        } catch let error as NSError {
        //            print("couldn't start notifier \(error.localizedDescription)")
        //        }
        
        
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
        print("\n\n\n\n\n\n\n\nInside reachability method APPDELEGATE\n\n\n\n\n")
        do {
            print("BEFORE")
            reachability = try Reachability.reachabilityForInternetConnection()
            print("AFTER")
            //try reachability?.startNotifier()
        } catch let error as NSError {
            print("Unable to start reachability \(error.localizedDescription)")
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reachabilityChanged)
            ,name: ReachabilityChangedNotification,object: reachability)
        
        do {
            try reachability?.startNotifier()
        } catch let error as NSError {
            print("couldn't start notifier \(error.localizedDescription)")
        }
    }
    
    func reachabilityChanged() {
        print("REACH: \(reachability)")
        print("\n\n\n\n\n\nInside reachability method\n\n\n\n\n\n\n\n")
        guard let reachability = reachability else { return }
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                //print(reachability)
                print("Reachable via WiFi@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
            } else {
                print("Reachable via Cellular")
            }
        } else {
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
    }
    
    func applicationWillTerminate(application: UIApplication) {
        AppDelegate.userDefaultWalkData.setValue(WalkTrackerViewController.walkTrackerSession.walkStartDate, forKey: "walkStartDate")
        AppDelegate.userDefaultWalkData.setValue(AppDelegate.activeWorkout, forKey: "workoutActive")
        WalkTrackerViewController.walkTrackerSession.walkTimer.invalidate()
    }
}
