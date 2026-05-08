//
//  TrackerRepository.swift
//  Tracker
//
//  Created by Irina Muravyeva on 28.04.2026.
//

import Foundation

final class TrackerRepository {
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    
    init(container: CoreDataContainer) {
        self.trackerStore = container.trackerStore
        self.categoryStore = container.categoryStore
        self.recordStore = container.recordStore
    }
}

extension TrackerRepository: TrackersFactoryProtocol {
    func getTrackersCategory() -> [TrackerCategory] {
        categoryStore.fetchCategories()
    }
    
    func getCompletedTrackers() -> [TrackerRecord] {
        recordStore.fetchAllRecords()
    }
    
    func trackerRecordsDidUpdated(with record: TrackerRecord) {
        try? recordStore.addRecord(record)
    }
    
    func trackerRecordDidCanceled(for trackerId: UUID, at data: Date) {
        let record = TrackerRecord(trackerId: trackerId, date: data)
        try? recordStore.deleteRecord(record)
    }
    
    func trackerDidAdd(_ tracker: Tracker, category: String) {
        try? trackerStore.add(tracker, to: category)
    }
    
    func addCategory(_ title: String) {
        try? categoryStore.addCategory(title)
    }
}
