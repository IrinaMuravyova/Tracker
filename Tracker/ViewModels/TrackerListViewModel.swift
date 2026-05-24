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
    
    private(set) var sections: [TrackerSectionUIModel] = []
    
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
    
    // MARK: - Private methods
    private func reload() {
        var sections: [TrackerSectionUIModel] = []

        let calendar = Calendar.current

        let weekdayNumber = calendar.component(.weekday, from: selectedDate)

        guard let currentWeekday = Weekday(calendarWeekday: weekdayNumber) else {
            sections = []
            onChange?()
            return
        }
        
        let records = recordStore.records()

        for sectionIndex in 0..<trackerStore.numberOfSections {

            var items: [TrackerUIModel] = []

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

                items.append(makeVM(tracker, records: records))
            }

            guard !items.isEmpty else { continue }
            
            let title = trackerStore.titleForSection(sectionIndex)

            sections.append(
                TrackerSectionUIModel(
                    title: title,
                    trackers: items
                )
            )
        }

        self.sections = sections

        onChange?()
    }
    
    private func makeVM(_ tracker: Tracker,
                        records: [TrackerRecord]) -> TrackerUIModel {
        
        let trackerRecords = records.filter {
            $0.trackerId == tracker.id
        }
        
        let isDoneToday = trackerRecords.contains {
            return Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }

        return TrackerUIModel(
            id: tracker.id,
            name: tracker.name,
            emoji: tracker.emoji,
            color: tracker.color,
            completedCount: trackerRecords.count,
            isDoneToday: isDoneToday,
            isPinned: tracker.isPinned
        )
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
