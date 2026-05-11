//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Irina Muravyeva on 20.04.2026.
//

import UIKit
import CoreData

enum TrackerRecordStoreError: Error {
    case trackerNotFound
    case recordAlreadyExists
}

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

final class TrackerRecordStore: NSObject {
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
    }
    
    // MARK: - CRUD functions
    func addRecord(_ record: TrackerRecord) throws {
        if let _ = try findRecord(record) {
            throw TrackerRecordStoreError.recordAlreadyExists
        } else {
    
            let recordCoreData = TrackerRecordCoreData(context: context)
            recordCoreData.date = record.date
            
            let trackerRequest = TrackerCoreData.fetchRequest()
            trackerRequest.predicate = NSPredicate(format: "id == %@", record.trackerId as CVarArg)
            
            guard let trackerCoreData = try context.fetch(trackerRequest).first else {
                throw TrackerRecordStoreError.trackerNotFound
            }
            
            recordCoreData.tracker = trackerCoreData
            
            try context.save()
        }
    }
    
    func deleteRecord(_ record: TrackerRecordCoreData) throws {
        context.delete(record)
        try context.save()
    }

    // MARK: - Helper functions
    func findRecord(_ record: TrackerRecord) throws -> TrackerRecordCoreData? {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND date == %@",
            record.trackerId as CVarArg,
            record.date as CVarArg
        )
        return try context.fetch(request).first
    }
}

// MARK: - TrackerRecordFetchedResultsControllerProtocol
extension TrackerRecordStore: TrackerRecordFetchedResultsControllerProtocol {
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
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerRecordStoreDidChangeContent()
    }
}
