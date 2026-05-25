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
protocol TrackerStoreProtocol {
    var numberOfSections: Int { get }
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> Tracker
    func performFetch() throws
    func titleForSection(_ section: Int) -> String
    
    var delegate: TrackerStoreDelegate? { get set }
    
    func togglePinned(for id: UUID) throws
}

// MARK: - TrackerFetchedResultsControllerDelegate
protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChangeContent()
}

final class TrackerStore: NSObject {
    // MARK: - Private properties
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
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
    weak var delegate: TrackerStoreDelegate?

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
        trackerCoreData.isPinned = tracker.isPinned
        
        try context.save()
    }
    
    func delete(_ tracker: TrackerCoreData) throws {
        context.delete(tracker)
        try context.save()
    }

    func togglePinned(for id: UUID) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let tracker = try context.fetch(request).first else {
            throw TrackerStoreError.trackerNotFound
        }

        tracker.isPinned.toggle()
        
        try context.save()
    }
    
    func updateTracker(
        id: UUID,
        title: String,
        category: String,
        schedule: Set<Weekday>,
        emoji: String,
        color: TrackerColor
    ) throws {

        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let tracker = try context.fetch(request).first else {
            throw TrackerStoreError.trackerNotFound
        }

        let categoryStore = TrackerCategoryStore(context: context)
        let categoryCoreData = categoryStore.fetchCategory(by: category)

        guard let categoryCoreData else {
            throw TrackerStoreError.categoryNotFound
        }

        tracker.name = title
        tracker.category = categoryCoreData
        tracker.emoji = emoji
        tracker.color = color.rawValue

        let updatedSchedule = TrackerSchedule.daysOfWeek(schedule)
        tracker.schedule = try? JSONEncoder().encode(updatedSchedule)

        try context.save()
    }
}

extension TrackerStore: TrackerStoreProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> Tracker {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return mapToTracker(trackerCoreData)
    }
    
    func performFetch() throws {
           try fetchedResultsController.performFetch()
       }
    
    func titleForSection(_ section: Int) -> String {
        fetchedResultsController.sections?[section].name ?? ""
    }
}

// MARK: - Private methods
private extension TrackerStore {
    func mapToTracker(_ coreData: TrackerCoreData) -> Tracker {
        let schedule: TrackerSchedule = {
            guard let data = coreData.schedule,
                  let decoded = try? JSONDecoder().decode(TrackerSchedule.self, from: data)
            else {
                return .daysOfWeek([])
            }
            return decoded
        }()
        
        return Tracker(
            id: coreData.id ?? UUID(),
            name: coreData.name ?? "",
            color: TrackerColor.from(coreData.color),
            emoji: coreData.emoji ?? "",
            schedule: schedule,
            type: TrackerType(rawValue: coreData.type ?? "") ?? .habit,
            isPinned: coreData.isPinned
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidChangeContent()
    }
}
