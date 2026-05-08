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
    let trackerFetchedResultsController: TrackerFetchedResultsController

    init(context: NSManagedObjectContext) {
        self.categoryStore = TrackerCategoryStore(context: context)
        self.recordStore = TrackerRecordStore(context: context)
        self.trackerStore = TrackerStore(context: context/*, recordStore: recordStore*/)
        self.trackerFetchedResultsController = TrackerFetchedResultsController(context: context)
    }
}
