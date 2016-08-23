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
    
    var paths: [FullPath] = []
    
    // MARK: - Functions
    
    func savePath(waypoints: [Waypoint], duration: String) {
        var coordinates: [Coordinate] = []
        
        for waypoint in waypoints {
            let coordinate: Coordinate = insertNewCoordinateObject()
            coordinate.latitude = Double(waypoint.coordinate.latitude)
            coordinate.longitude = Double(waypoint.coordinate.longitude)
            
            coordinates.append(coordinate)
        }
        
        let path: FullPath = insertNewPathObject()
        path.createdAt = NSDate()
        path.duration = duration
        path.waypoints = Set(coordinates)
        
        saveContext()
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
        let pathRequest = NSFetchRequest(entityName: "FullPath")
        
        do {
            paths = try managedObjectContext.executeFetchRequest(pathRequest) as! [FullPath]
        } catch let error as NSError {
            print("Error: \(error): \(error.userInfo)")
            paths = []
        }
    }
    
    // MARK: - Helpers
    
    func insertNewCoordinateObject() -> Coordinate {
        let coordinate: Coordinate = NSEntityDescription.insertNewObjectForEntityForName("Coordinate", inManagedObjectContext: managedObjectContext) as! Coordinate
        
        return coordinate
    }
    
    func insertNewPathObject() -> FullPath {
        let path: FullPath = NSEntityDescription.insertNewObjectForEntityForName("FullPath", inManagedObjectContext: managedObjectContext) as! FullPath
        
        return path
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