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
    let recordFetchedResultsController: TrackerRecordFetchedResultsController

    init(context: NSManagedObjectContext) {
        self.categoryStore = TrackerCategoryStore(context: context)
        self.recordStore = TrackerRecordStore(context: context)
        self.trackerStore = TrackerStore(context: context)
        self.trackerFetchedResultsController = TrackerFetchedResultsController(context: context)
        self.recordFetchedResultsController = TrackerRecordFetchedResultsController(context: context)
    }
}
