//
//  TrackerRecordFetchedResultsController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 09.05.2026.
//

import CoreData

// MARK: - TrackerRecordFetchedResultsControllerProtocol
protocol TrackerRecordFetchedResultsControllerProtocol {
    var delegate: TrackerRecordFetchedResultsControllerDelegate? { get set }

    func performFetch() throws
    func numberOfObjects() -> Int
    func object(at indexPath: IndexPath) -> TrackerRecordCoreData
    func fetchedObjects() -> [TrackerRecordCoreData]
    func fetchRecord(trackerId: UUID, date: Date) -> TrackerRecordCoreData?
}

// MARK: - TrackerRecordFetchedResultsControllerDelegate
protocol TrackerRecordFetchedResultsControllerDelegate: AnyObject {
    func trackerRecordStoreDidChangeContent()
}

final class TrackerRecordFetchedResultsController: NSObject {
    // MARK: - Private properties
    private let context: NSManagedObjectContext

    private lazy var frc: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]

        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        frc.delegate = self
        return frc
    }()

    // MARK: - Public properties
    weak var delegate: TrackerRecordFetchedResultsControllerDelegate?

    // MARK: - Initializes
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
}

// MARK: - TrackerRecordFetchedResultsControllerProtocol
extension TrackerRecordFetchedResultsController: TrackerRecordFetchedResultsControllerProtocol {
    func performFetch() throws {
        try frc.performFetch()
    }

    func numberOfObjects() -> Int {
        frc.fetchedObjects?.count ?? 0
    }

    func object(at indexPath: IndexPath) -> TrackerRecordCoreData {
        frc.object(at: indexPath)
    }
    
    func fetchedObjects() -> [TrackerRecordCoreData] {
        do {
            try frc.performFetch()
        } catch {
            print("[TrackerRecordFetchedResultsController] Failed to fetch: \(error)")
        }
        
        return frc.fetchedObjects ?? []
    }
    
    func fetchRecord(trackerId: UUID, date: Date) -> TrackerRecordCoreData? {
        frc.fetchedObjects?.first {
            guard let recordDate = $0.date else { return false }

            return $0.tracker?.id == trackerId &&
            Calendar.current.isDate(recordDate, inSameDayAs: date)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordFetchedResultsController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerRecordStoreDidChangeContent()
    }
}
