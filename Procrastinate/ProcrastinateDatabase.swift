//
//  ProcrastinateDatabase.swift
//  Procrastinate
//
//  Created by Aneta on 22.10.2016.
//  Copyright © 2016 Aneta Różniewicz. All rights reserved.
//

import Foundation
import CoreData

class ProcrastinateDatabase {
    
    static let instance = ProcrastinateDatabase()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Procrastinate")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.undoManager = UndoManager()
        
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    func fetch<T>(type: T.Type) -> [T] where T: NSManagedObject {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))

        do {
            return try self.mainContext.fetch(request)
        } catch {
            debugPrint(error)
            
            return []
        }
    }
    
    func undo() {
        self.mainContext.undo()
    }
    
    func delete(object: NSManagedObject) {
        self.mainContext.delete(object)
    }
    
    func saveContext() {
        if self.mainContext.hasChanges {
            do {
                try self.mainContext.save()
            } catch {
                debugPrint(error)
            }
        }
    }
}
