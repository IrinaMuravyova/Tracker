//
//  TrackerListViewModel.swift
//  Tracker
//
//  Created by Irina Muravyeva on 06.05.2026.
//

import UIKit

final class TrackerListViewModel: TrackerFetchedResultsControllerDelegate {
    // MARK: - Private properties
    private var frc: TrackerFetchedResultsControllerProtocol
    private var recordFRC: TrackerRecordFetchedResultsControllerProtocol
    private let recordStore: TrackerRecordStore
    
    private(set) var sections: [TrackerSectionViewModel] = []
    
    private var selectedDate: Date = Date()
    
    // MARK: - Public properties
    var onChange: (() -> Void)?
    
    // MARK: - Initializes
    init(frc: TrackerFetchedResultsControllerProtocol,
         recordFRC: TrackerRecordFetchedResultsControllerProtocol,
         recordStore: TrackerRecordStore) {
        self.frc = frc
        self.recordFRC = recordFRC
        self.recordStore = recordStore
        
        self.frc.delegate = self
        self.recordFRC.delegate = self
        
        do {
            try frc.performFetch()
            try recordFRC.performFetch()
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
            let existingRecord = recordFRC.fetchRecord(
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
    
    // MARK: - Private methods
    private func reload() {
        var sections: [TrackerSectionViewModel] = []

        let calendar = Calendar.current

        let weekdayNumber = calendar.component(.weekday, from: selectedDate)

        guard let currentWeekday = Weekday(calendarWeekday: weekdayNumber) else {
            sections = []
            onChange?()
            return
        }
        
        let records = recordFRC.fetchedObjects()

        for sectionIndex in 0..<frc.numberOfSections {

            var items: [TrackerViewModel] = []

            let rows = frc.numberOfRowsInSection(sectionIndex)

            for row in 0..<rows {
                let indexPath = IndexPath(row: row, section: sectionIndex)

                let coreData = frc.object(at: indexPath)
                let tracker = mapToTracker(coreData)

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
                        $0.tracker?.id == tracker.id
                    }

                    if trackerRecords.isEmpty {
                        break
                    }
                    
                    let hasRecord = trackerRecords.contains {
                        guard let date = $0.date else { return false }
                        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    }

                    guard hasRecord else { continue }
                }

                items.append(makeVM(coreData, records: records))
            }

            guard !items.isEmpty else { continue }
            
            let title = frc.titleForSection(sectionIndex)

            sections.append(
                TrackerSectionViewModel(
                    title: title,
                    trackers: items
                )
            )
        }

        self.sections = sections
        onChange?()
    }
    
    private func makeVM(_ coreData: TrackerCoreData,
                        records: [TrackerRecordCoreData]) -> TrackerViewModel {
        let tracker = mapToTracker(coreData)

        let trackerRecords = records.filter {
            $0.tracker?.id == tracker.id
        }
        
        let isDoneToday = trackerRecords.contains {
            guard let date = $0.date else { return false }

            return Calendar.current.isDate(date, inSameDayAs: selectedDate)
        }

        return TrackerViewModel(
            id: tracker.id,
            name: tracker.name,
            emoji: tracker.emoji,
            color: tracker.color,
            completedCount: trackerRecords.count,
            isDoneToday: isDoneToday
        )
    }
    
    private func mapToTracker(_ coreData: TrackerCoreData) -> Tracker {
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
            type: TrackerType(rawValue: coreData.type ?? "") ?? .habit
        )
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        let calendar = Calendar.current

        return calendar.startOfDay(for: date)
        > calendar.startOfDay(for: Date())
    }
}

// MARK: - TrackerRecordFetchedResultsControllerDelegate
extension TrackerListViewModel: TrackerRecordFetchedResultsControllerDelegate {
    func trackerRecordStoreDidChangeContent() {
        reload()
    }
}
