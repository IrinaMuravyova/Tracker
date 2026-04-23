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

final class TrackerStore {
    private let context: NSManagedObjectContext

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addNewTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker, and: category)
        try context.save()
    }

    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker, and category: TrackerCategory) throws {
        trackerCoreData.id = tracker.id
        trackerCoreData.type = tracker.type.rawValue
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.rawValue

        let existingCategoriesCoreData = TrackerCategoryCoreData.fetchRequest()
        existingCategoriesCoreData.predicate = NSPredicate(
            format: "title == %@",
            category.title as CVarArg
        )
       
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)

        let results = try context.fetch(request)

        guard let categoryCoreData = results.first else {
            throw TrackerStoreError.categoryNotFound
        }

        trackerCoreData.category = categoryCoreData
        
        try context.save()
    }
}
