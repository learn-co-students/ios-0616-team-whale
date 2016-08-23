//
//  FullPath+CoreDataProperties.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/22/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FullPath {

    @NSManaged var createdAt: NSDate?
    @NSManaged var duration: String?
    @NSManaged var waypoints: Set<Coordinate>?

}
