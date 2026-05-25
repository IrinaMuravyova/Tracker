//
//  TrackerListViewModel.swift
//  Tracker
//
//  Created by Irina Muravyeva on 06.05.2026.
//

import UIKit

final class TrackerListViewModel: TrackerStoreDelegate {
    // MARK: - Private properties
    private var trackerStore: TrackerStoreProtocol
    private var recordStore: TrackerRecordStoreProtocol
    private let container: CoreDataContainer
    
    private(set) var sections: [TrackerSectionModel] = []
    private var allTrackersWithCategories: [(tracker: Tracker, category: String)] = []
    private var selectedDate: Date = Date()
    
    // MARK: - Public properties
    var onChange: (() -> Void)?
    var showAlert: ((String, String) -> Void)?
    
    // MARK: - Initializes
    init(
        container: CoreDataContainer
    ) {
        self.container = container
        self.trackerStore = container.trackerStore
        self.recordStore = container.recordStore
        
        self.trackerStore.delegate = self
        self.recordStore.delegate = self
        
        do {
            try self.trackerStore.performFetch()
            try self.recordStore.performFetch()
        } catch {
            print(error)
        }
        
        loadTrackersWithCategories()
    }
    
    // MARK: - Public methods
    func trackerStoreDidChangeContent() {
        loadTrackersWithCategories()
        reload()
    }
    
    func setDate(_ date: Date) {
        selectedDate = date
        reload()
    }
    
    func toggleTracker(at indexPath: IndexPath) {
        let tracker = sections[indexPath.section].trackers[indexPath.row]

        guard !isFutureDate(selectedDate) else {
            showAlert?(
                NSLocalizedString(
                    "alert_title",
                    comment: "Title for alert when trying to select future date"),
                NSLocalizedString(
                    "alert_message_for_future_date",
                    comment: "Message telling user that habit cannot be marked for future date"
                )
            )
            return
        }
        
        let record = TrackerRecord(
            trackerId: tracker.id,
            date: selectedDate
        )
        
        do {
            let existingRecord = recordStore.record(
                trackerId: tracker.id,
                date: selectedDate
            )
     
            if let record = existingRecord {
                try recordStore.deleteRecord(record)
            } else {
                try recordStore.addRecord(record)
            }
            
            reload()
        } catch {
            print(error)
        }
    }
    
    func togglePinned(at id: UUID) {
        do {
            try trackerStore.togglePinned(for: id)
            onChange?()
        } catch {
            print(error)
        }
    }
    
    func makeEditTrackerViewModel(tracker: Tracker) -> EditTrackerViewModel {
        EditTrackerViewModel(tracker: tracker, container: container)
    }
    
    func state(for tracker: Tracker) -> TrackerCellState {
        let records = recordStore.records()

        var completedCount = 0
        var isDoneToday = false

        for record in records {
            guard record.trackerId == tracker.id else { continue }

            completedCount += 1

            if !isDoneToday,
               Calendar.current.isDate(record.date, inSameDayAs: Date()) {
                isDoneToday = true
            }
        }

        return TrackerCellState(
            completedCount: completedCount,
            isDoneToday: isDoneToday
        )
    }
    
    func updateSections() {
        reload()
    }
    
    // MARK: - Private methods
    private func isFutureDate(_ date: Date) -> Bool {
        let calendar = Calendar.current

        return calendar.startOfDay(for: date)
        > calendar.startOfDay(for: Date())
    }
    
    private func loadTrackersWithCategories() {
        var trackersWithCategories: [(tracker: Tracker, category: String)] = []
        
        for section in 0..<trackerStore.numberOfSections {
            let categoryTitle = trackerStore.titleForSection(section)
            
            for row in 0..<trackerStore.numberOfRowsInSection(section) {
                let indexPath = IndexPath(row: row, section: section)
                let tracker = trackerStore.object(at: indexPath)
                trackersWithCategories.append((tracker: tracker, category: categoryTitle))
            }
        }
        
        allTrackersWithCategories = trackersWithCategories
        reload()
    }
    
    private func reload() {
        let filteredTrackers = filterTrackersByDate(allTrackersWithCategories)
        let newSections = buildSections(from: filteredTrackers)
        sections = newSections
        onChange?()
    }
    
    private func filterTrackersByDate(_ trackersWithCategories: [(tracker: Tracker, category: String)]) -> [(tracker: Tracker, category: String)] {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: selectedDate)
        
        guard let currentWeekday = Weekday(calendarWeekday: weekdayNumber) else {
            return []
        }
        
        let records = recordStore.records()
        
        return trackersWithCategories.filter { item in
            let tracker = item.tracker
            
            switch tracker.type {
            case .habit:
                switch tracker.schedule {
                case .daysOfWeek(let days):
                    return days.contains(currentWeekday)
                }
                
            case .irregular:
                let trackerRecords = records.filter { $0.trackerId == tracker.id }
                
                guard !trackerRecords.isEmpty else { return false }
                
                return trackerRecords.contains { record in
                    Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
                }
            }
        }
    }
    
    private func buildSections(from trackersWithCategories: [(tracker: Tracker, category: String)]) -> [TrackerSectionModel] {
        var sections: [TrackerSectionModel] = []
        
        let pinnedTrackers = trackersWithCategories.filter { $0.tracker.isPinned }.map { $0.tracker }
        let regularTrackersWithCategories = trackersWithCategories.filter { !$0.tracker.isPinned }
        
        if !pinnedTrackers.isEmpty {
            sections.append(TrackerSectionModel(
                title: NSLocalizedString(
                    "pinned",
                    comment: "Title for group of pinned trackers"
                ),
                trackers: pinnedTrackers
            ))
        }
        
        let groupedByCategory = Dictionary(grouping: regularTrackersWithCategories) { $0.category }
        
        let sortedCategories = groupedByCategory.sorted { $0.key < $1.key }
        
        for (categoryTitle, items) in sortedCategories {
            let trackers = items.map { $0.tracker }
            sections.append(TrackerSectionModel(
                title: categoryTitle,
                trackers: trackers
            ))
        }
        
        return sections
    }
}

// MARK: - TrackerRecordFetchedResultsControllerDelegate
extension TrackerListViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChangeContent() {
        reload()
    }
}
