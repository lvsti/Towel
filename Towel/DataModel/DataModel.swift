//
//  DataModel.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 07..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import CoreData

class DataModel {
    static let instance = DataModel()
    
    private let _dbController: DBController
    
    private init() {
        _dbController = DBController.instance
    }
    
    func getAllPlaces() throws -> [Place] {
        let request = NSFetchRequest(entityName: "Place")
        return try _dbController.managedObjectContext.executeFetchRequest(request) as! [Place]
    }
    
}
