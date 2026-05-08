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
    private let recordStore: TrackerRecordStore
    
    private(set) var sections: [TrackerSectionViewModel] = []
    
    private var selectedDate: Date = Date()
    
    // MARK: - Public properties
    var onChange: (() -> Void)?
    
    // MARK: - Initializes
    init(frc: TrackerFetchedResultsControllerProtocol,
         recordStore: TrackerRecordStore) {
        self.frc = frc
        self.recordStore = recordStore
        
        self.frc.delegate = self
        
        do {
            try frc.performFetch()
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
        applyFilter()
    }
    
    // MARK: - Private methods
    private func reload() {
        var sections: [TrackerSectionViewModel] = []

        for sectionIndex in 0..<frc.numberOfSections {

            var items: [TrackerViewModel] = []

            let rows = frc.numberOfRowsInSection(sectionIndex)

            for row in 0..<rows {
                let indexPath = IndexPath(row: row, section: sectionIndex)

                let coreData = frc.object(at: indexPath)
                items.append(makeVM(coreData))
            }

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
    
    private func makeVM(_ coreData: TrackerCoreData) -> TrackerViewModel {
        let tracker = mapToTracker(coreData)

        let count = recordStore.getRecordCoreData(for: tracker.id).count

        let isDone = false //TODO: позже добавить date-based

        return TrackerViewModel(
            id: tracker.id,
            name: tracker.name,
            emoji: tracker.emoji,
            color: tracker.color,
            completedCount: count,
            isDoneToday: isDone
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
    
    private func applyFilter() {
        //TODO: позже добавить фильтрацию
//        fetchedResultsController.applyFilter(for: currentDate)
    }
}
