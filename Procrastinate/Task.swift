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
    @NSManaged var frequency: NSNumber
    @NSManaged var repeatsEvery: NSNumber
    
    var frequencyEnum: TaskFrequency {
        get {
            return TaskFrequency(rawValue: self.frequency.intValue) ?? .once
        }
        set {
            self.frequency = NSNumber(value: newValue.rawValue)
        }
    }
    
    private let defaultDescription = ""
    private let defaultDeadline = Date().noon
    private let defaultFrequency = TaskFrequency.once.rawValue
    private let defaultRepeats = 0
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        setPrimitiveValue(self.defaultDescription, forKey: "taskDescription")
        setPrimitiveValue(self.defaultDeadline, forKey: "deadline")
        setPrimitiveValue(self.defaultFrequency, forKey: "frequency")
        setPrimitiveValue(self.defaultRepeats, forKey: "repeatsEvery")
    }
    
    func complete() {
        let repeatsEvery = self.repeatsEvery.intValue
        
        switch self.frequencyEnum {
        case .daily: self.deadline = self.deadline.adding(days: repeatsEvery)
        case .weekly: self.deadline = self.deadline.adding(weeks: repeatsEvery)
        case .monthly: self.deadline = self.deadline.adding(months: repeatsEvery)
        case .yearly: self.deadline = self.deadline.adding(years: repeatsEvery)
        default: break
        }
    }
    
}
