//
//  PlaceDescription+CoreDataProperties.swift
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

extension PlaceDescription {

    @NSManaged var languageID: String
    @NSManaged var text: String
    @NSManaged var timestamp: NSDate?
    @NSManaged var placeInfo: NSManagedObject
    @NSManaged var user: User?

}
