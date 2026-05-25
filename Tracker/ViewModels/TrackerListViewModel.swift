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
    
    private var selectedDate: Date = Date()
    
    // MARK: - Public properties
    var onChange: (() -> Void)?
    
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
        
        reload()
    }
    
    // MARK: - Public methods
    func trackerStoreDidChangeContent() {
        reload()
    }
    
    func setDate(_ date: Date) {
        selectedDate = date
        reload()
    }
    
    func toggleTracker(at indexPath: IndexPath) {
        let tracker = sections[indexPath.section].trackers[indexPath.row]

        guard !isFutureDate(selectedDate) else { return }

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
    private func reload() {
        var sections: [TrackerSectionModel] = []

        let calendar = Calendar.current

        let weekdayNumber = calendar.component(.weekday, from: selectedDate)

        guard let currentWeekday = Weekday(calendarWeekday: weekdayNumber) else {
            sections = []
            onChange?()
            return
        }
        
        let records = recordStore.records()

        for sectionIndex in 0..<trackerStore.numberOfSections {

            var items: [Tracker] = []

            let rows = trackerStore.numberOfRowsInSection(sectionIndex)

            for row in 0..<rows {
                let indexPath = IndexPath(row: row, section: sectionIndex)

                let tracker = trackerStore.object(at: indexPath)

                // MARK: - Filter by selected date
                switch tracker.type {

                case .habit:
                    let shouldShow: Bool

                    switch tracker.schedule {
                    case .daysOfWeek(let days):
                        shouldShow = days.contains(currentWeekday)
                    }

                    guard shouldShow else { continue }

                case .irregular:
                    let trackerRecords = records.filter {
                        $0.trackerId == tracker.id
                    }

                    if trackerRecords.isEmpty {
                        break
                    }
                    
                    let hasRecord = trackerRecords.contains {
                        return Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                    }

                    guard hasRecord else { continue }
                }

                items.append(tracker)
            }

            guard !items.isEmpty else { continue }
            
            let title = trackerStore.titleForSection(sectionIndex)

            sections.append(
                TrackerSectionModel(
                    title: title,
                    trackers: items
                )
            )
        }

        self.sections = sections

        onChange?()
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        let calendar = Calendar.current

        return calendar.startOfDay(for: date)
        > calendar.startOfDay(for: Date())
    }
}

// MARK: - TrackerRecordFetchedResultsControllerDelegate
extension TrackerListViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChangeContent() {
        reload()
    }
}
