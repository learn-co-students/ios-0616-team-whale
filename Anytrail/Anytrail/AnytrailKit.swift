//
//  AnytrailKit.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/18/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import CoreData
import MapboxDirections

class AnytrailKit {
    
    static let sharedInstance = AnytrailKit()
    
    var paths = []
    
    // MARK: - Functions
    
    class func savePath(waypoints: [Waypoint]) {
        var coordinates: [(Double, Double)] = []
        
        for waypoint in waypoints {
            coordinates.append((Double(waypoint.coordinate.latitude), (Double(waypoint.coordinate.longitude))))
        }
        
        print("Coordinates: \(coordinates)")
    }
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Error: \(error): \(error.userInfo)")
                abort()
            }
        }
        
        fetchData()
    }
    
    func fetchData() {
//        let pirateRequest = NSFetchRequest(entityName: "Pirate")
//        
//        do {
//            pirates = try managedObjectContext.executeFetchRequest(pirateRequest) as! [Pirate]
//        } catch let error as NSError {
//            print("Error: \(error): \(error.userInfo)")
//            pirates = []
//        }
//        
//        if pirates.count == 0 {
//            buildShip()
//        }
    }
    
    // MARK: - Helpers
    
    func insertNewShipObject() -> Void {
//        let ship: Ship = NSEntityDescription.insertNewObjectForEntityForName("Ship", inManagedObjectContext: managedObjectContext) as! Ship
//        
//        return ship
    }
    
    // MARK: - Core Data stack
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Paths", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Paths.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    // MARK: - Application's Documents directory
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
}