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

protocol TrackerStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> Tracker?
    func performFetch() throws
    
    func add(_ tracker: Tracker, to category: String) throws
    func fetchAllTrackers() throws -> [Tracker]
}

final class TrackerStore: NSObject {
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
        
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    private let context: NSManagedObjectContext
    weak var delegate: NSFetchedResultsControllerDelegate?
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

// MARK: - Public functions, TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let coreData = fetchedResultsController.object(at: indexPath)
        return mapToTracker(coreData)
    }
    
    func performFetch() throws {
           try fetchedResultsController.performFetch()
       }
    
    func add(_ tracker: Tracker, to category: String) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", tracker.name)
        
        let existingTrackers = try context.fetch(request)
        
        if existingTrackers.isEmpty {
            
            let categoryStore = TrackerCategoryStore(context: context)
            let categoryCoreData = categoryStore.fetchCategory(by: category)

            print(type(of: tracker.schedule))
           
            
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = UUID()
            trackerCoreData.name = tracker.name
            trackerCoreData.category = categoryCoreData
            trackerCoreData.color = tracker.color.rawValue
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.schedule = ScheduleWrapper(tracker.schedule)
            trackerCoreData.type = tracker.type.rawValue
            try context.save()
            
            // add tracker to category
            
        } else {
            throw TrackerStoreError.trackerAlreadyExists
        }
    }
    
    func fetchAllTrackers() throws -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let results = try context.fetch(request)
        return results.compactMap { mapToTracker($0) }
    }
}

// MARK - Private functions
private extension TrackerStore {
    func mapToTracker(_ coreData: TrackerCoreData) -> Tracker {
        Tracker(
            id: coreData.id ?? UUID(),
            name: coreData.name ?? "",
            color: TrackerColor.from(coreData.color),
            emoji: coreData.emoji ?? "",
            schedule: {
                let days = coreData.schedule as? Set<Weekday> ?? []
                return .daysOfWeek(days)
            }(),
            type: TrackerType(rawValue: coreData.type ?? "") ?? .habit
        )
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerDidChangeContent?(controller)
    }
}
