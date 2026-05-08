//
//  Helper.swift
//  TrackerTests
//
//  Created by Irina Muravyeva on 06.05.2026.
//

import CoreData

var inMemoryContext: NSManagedObjectContext {
    let container = NSPersistentContainer(name: "TrackerModel")
    
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    
    container.persistentStoreDescriptions = [description]
    
    container.loadPersistentStores { _, error in
        if let error = error {
            fatalError("Failed to load store: \(error)")
        }
    }
    
    return container.viewContext
}
