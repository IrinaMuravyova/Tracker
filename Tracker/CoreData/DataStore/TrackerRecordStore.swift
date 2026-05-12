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

// MARK: - TrackerRecordStoreProtocol
protocol TrackerRecordStoreProtocol: AnyObject {
    var delegate: TrackerRecordStoreDelegate? { get set }

    func performFetch() throws
    
    func numberOfObjects() -> Int
    func object(at indexPath: IndexPath) -> TrackerRecord
    
    func fetchRecords() throws
    func records() -> [TrackerRecord]

    func addRecord(_ record: TrackerRecord) throws
    func deleteRecord(_ record: TrackerRecord) throws

    func record(trackerId: UUID, date: Date) -> TrackerRecord?
}

// MARK: - TrackerRecordStoreDelegate
protocol TrackerRecordStoreDelegate: AnyObject {
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
    weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Initializes
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

// MARK: - TrackerRecordStoreProtocol
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func performFetch() throws {
        try frc.performFetch()
    }
    
    func numberOfObjects() -> Int {
        frc.fetchedObjects?.count ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerRecord {
        guard let coreData = frc.fetchedObjects?[indexPath.item],
              let recordModel = makeTrackerRecord(from: coreData)
        else {
            fatalError("Invalid indexPath or corrupted data")
        }
        
        return recordModel
    }
    
    func fetchRecords() throws {
        try frc.performFetch()
    }
    
    func records() -> [TrackerRecord] {
        frc.fetchedObjects?.compactMap { makeTrackerRecord(from: $0) } ?? []
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        if let _ = try findRecord(record) {
            throw TrackerRecordStoreError.recordAlreadyExists
        } else {
            
            let trackerRequest = TrackerCoreData.fetchRequest()
            trackerRequest.predicate = NSPredicate(
                format: "id == %@",
                record.trackerId as CVarArg
            )
            
            guard let trackerCoreData = try context.fetch(trackerRequest).first else {
                throw TrackerRecordStoreError.trackerNotFound
            }
            
            let recordCoreData = TrackerRecordCoreData(context: context)
            recordCoreData.date = record.date
            recordCoreData.tracker = trackerCoreData
            
            try context.save()
        }
    }
    
    func deleteRecord(_ record: TrackerRecord) throws {
        guard let recordCoreData = try findRecord(record) else { return }
        
        context.delete(recordCoreData)
        try context.save()
    }
    
    func record(trackerId: UUID, date: Date) -> TrackerRecord? {
        
        frc.fetchedObjects?
            .first {
                guard let recordDate = $0.date else {
                    return false
                }
                
                return $0.tracker?.id == trackerId &&
                Calendar.current.isDate(recordDate, inSameDayAs: date)
            }
            .flatMap(makeTrackerRecord)
    }
}

// MARK: - Private methods
private extension TrackerRecordStore {
    func findRecord(_ record: TrackerRecord) throws -> TrackerRecordCoreData? {
        let request = TrackerRecordCoreData.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND date == %@",
            record.trackerId as CVarArg,
            record.date as CVarArg
        )
        
        return try context.fetch(request).first
    }
    
    func makeTrackerRecord(from coreData: TrackerRecordCoreData) -> TrackerRecord? {
        guard
            let trackerId = coreData.tracker?.id,
            let date = coreData.date
        else {
            return nil
        }

        return TrackerRecord(trackerId: trackerId, date: date)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerRecordStoreDidChangeContent()
    }
}
