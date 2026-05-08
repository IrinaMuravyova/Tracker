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

final class TrackerRecordStore {
    // MARK: - Private properties
    private let context: NSManagedObjectContext

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
    
    func deleteRecord(_ record: TrackerRecord) throws {
        guard let trackerRecordCoreData = try findRecord(record) else {
            throw TrackerRecordStoreError.trackerNotFound
        }
        
        context.delete(trackerRecordCoreData)
        try context.save()
    }
    
    func fetchAllRecords() -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results.compactMap { recordCD in
                guard let id = recordCD.tracker?.id,
                      let date = recordCD.date else { return nil }
                return TrackerRecord(trackerId: id, date: date)
            }
        } catch {
            print("Failed to fetch records: \(error)")
            return []
        }
    }
    
    func getRecordCoreData(for trackerId: UUID) -> [TrackerRecordCoreData] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
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
