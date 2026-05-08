//
//  TrackerStore.swift
//  Tracker
//
//  Created by Irina Muravyeva on 20.04.2026.
//

import UIKit
import CoreData

enum TrackerStoreError: Error {
    case categoryNotFound
    case trackerAlreadyExists
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
}

extension TrackerStore {
    func add(_ tracker: Tracker, to category: String) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", tracker.name)
        
        let existingTrackers = try context.fetch(request)
        
        if existingTrackers.isEmpty {
            
            let categoryStore = TrackerCategoryStore(context: context)
            let categoryCoreData = categoryStore.fetchCategory(by: category)
            
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = UUID()
            trackerCoreData.name = tracker.name
            trackerCoreData.category = categoryCoreData
            trackerCoreData.color = tracker.color.rawValue
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.schedule = try? JSONEncoder().encode(tracker.schedule)
            trackerCoreData.type = tracker.type.rawValue
            
            do {
                try context.save()
            } catch {
                print("Save error:", error)
            }
            
        } else {
            throw TrackerStoreError.trackerAlreadyExists
        }
    }
    
    func delete(_ tracker: TrackerCoreData) throws {
        context.delete(tracker)
        try context.save()
    }

    func fetchAllTrackers() throws -> [TrackerCoreData] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let results = try context.fetch(request)
        return results
    }
}
