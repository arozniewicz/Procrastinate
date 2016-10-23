//
//  Task.swift
//  Procrastinate
//
//  Created by Aneta on 16.10.2016.
//  Copyright © 2016 Aneta Różniewicz. All rights reserved.
//

import Foundation
import CoreData

@objc(Task)
class Task: NSManagedObject {
    
    @NSManaged var taskDescription: String
    @NSManaged var deadline: Date
    @NSManaged var repeats: NSNumber
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        setPrimitiveValue("", forKey: "taskDescription")
        setPrimitiveValue(Date().noon, forKey: "deadline")
    }
    
}
