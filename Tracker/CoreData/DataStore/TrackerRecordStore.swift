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
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - CRUD functions
    func addRecord(_ record: TrackerRecord, forTracker tracker: Tracker) throws {
        let existingRequest = TrackerRecordCoreData.fetchRequest()
        existingRequest.predicate = NSPredicate(
            format: "tracker.id == %@ AND date == %@",
            tracker.id as CVarArg,
            record.date as CVarArg
        )
        
        if try context.fetch(existingRequest).first != nil {
            throw TrackerRecordStoreError.recordAlreadyExists
        }
        
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.date = record.date
        
        let trackerRequest = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        guard let trackerCoreData = try context.fetch(trackerRequest).first else {
            throw TrackerRecordStoreError.trackerNotFound
        }
        
        recordCoreData.tracker = trackerCoreData
        
        try context.save()
    }
    
    func deleteRecord(_ record: TrackerRecord) throws {
        guard let trackerRecordCoreData = try findRecord(record) else {
            throw TrackerRecordStoreError.trackerNotFound
        }
        
        context.delete(trackerRecordCoreData)
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
