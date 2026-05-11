//
//  CoreDataContainer.swift
//  Tracker
//
//  Created by Irina Muravyeva on 28.04.2026.
//

import CoreData

final class CoreDataContainer {
    // MARK: - Private properties
    private let persistentContainer: NSPersistentContainer
    
    // MARK: - Public properties
    let trackerStore: TrackerStore
    let categoryStore: TrackerCategoryStore
    let recordStore: TrackerRecordStore

    init() {
        let container = NSPersistentContainer(name: "TrackerModel")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
#if DEBUG
            assertionFailure("Unresolved error \(error), \(error.userInfo)")
#else
            print("Core Data error: \(error), \(error.userInfo)")
#endif
            }
        })
        
        self.persistentContainer = container
        
        let context = container.viewContext
        
        self.categoryStore = TrackerCategoryStore(context: context)
        self.recordStore = TrackerRecordStore(context: context)
        self.trackerStore = TrackerStore(context: context)
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
#if DEBUG
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
#else
            print("Unresolved error \(nsError), \(nsError.userInfo)")
#endif
        }
    }
}
