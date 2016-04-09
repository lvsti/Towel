//
//  PlaceInfo+CoreDataProperties.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 03. 27..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PlaceInfo {

    @NSManaged var link: String?
    @NSManaged var placeID: Int32
    @NSManaged var altitude: Double
    @NSManaged var avgWaitingMinutes: NSNumber?
    @NSManaged var waitingCount: Int16
    @NSManaged var place: Place?
    @NSManaged var comments: NSSet?
    @NSManaged var location: Location?
    @NSManaged var descriptions: NSSet?
    @NSManaged var user: User?

}
