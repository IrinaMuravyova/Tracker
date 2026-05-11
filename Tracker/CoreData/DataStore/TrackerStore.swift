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
    case trackerNotFound
}

// MARK: - TrackerFetchedResultsControllerProtocol
protocol TrackerFetchedResultsControllerProtocol {
    var numberOfSections: Int { get }
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackerCoreData
    func performFetch() throws
    func titleForSection(_ section: Int) -> String
    
    var delegate: TrackerFetchedResultsControllerDelegate? { get set }
}

// MARK: - TrackerFetchedResultsControllerDelegate
protocol TrackerFetchedResultsControllerDelegate: AnyObject {
    func trackerStoreDidChangeContent()
}

final class TrackerStore: NSObject {
    // MARK: - Private properties
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil)
         
        return fetchedResultsController
    }()
    
    // MARK: - Public properties
    weak var delegate: TrackerFetchedResultsControllerDelegate?

    // MARK: - Initializes
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        fetchedResultsController.delegate = self
    }
}

// MARK: - Public functions
extension TrackerStore {
    func add(_ tracker: Tracker, to category: String) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", tracker.name)
        
        let existingTrackers = try context.fetch(request)
        
        guard existingTrackers.isEmpty else {
            throw TrackerStoreError.trackerAlreadyExists
        }
                
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
        
        try context.save()
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

extension TrackerStore: TrackerFetchedResultsControllerProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCoreData {
        fetchedResultsController.object(at: indexPath)
    }
    
    func performFetch() throws {
           try fetchedResultsController.performFetch()
       }
    
    func titleForSection(_ section: Int) -> String {
        fetchedResultsController.sections?[section].name ?? ""
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidChangeContent()
    }
}
