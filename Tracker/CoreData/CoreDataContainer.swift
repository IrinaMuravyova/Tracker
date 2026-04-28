//
//  CoreDataContainer.swift
//  Tracker
//
//  Created by Irina Muravyeva on 28.04.2026.
//

import CoreData

final class CoreDataContainer {
    let trackerStore: TrackerStore
    let categoryStore: TrackerCategoryStore
    let recordStore: TrackerRecordStore

    init(context: NSManagedObjectContext) {
        self.trackerStore = TrackerStore(context: context)
        self.categoryStore = TrackerCategoryStore(context: context)
        self.recordStore = TrackerRecordStore(context: context)
    }
}
