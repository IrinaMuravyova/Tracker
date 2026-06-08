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
    private let filterSettingsService = FilterSettingsService()
    
    private(set) var sections: [TrackerSectionModel] = []
    private var allTrackersWithCategories: [(tracker: Tracker, category: String)] = []
    private(set) var selectedDate: Date = Date()
    private(set) var currentFilter: FilterOption {
        didSet {
            filterSettingsService.saveFilter(currentFilter)
        }
    }
    private(set) var searchText: String = ""
    private(set) var isSearchActive: Bool = false
    
    // MARK: - Public properties
    var onChange: (() -> Void)?
    var showAlert: ((String, String) -> Void)?
    var onFilterChanged: ((FilterOption) -> Void)?
    var onDateChangeRequested: ((Date) -> Void)?
    
    // MARK: - Initializes
    init(
        container: CoreDataContainer
    ) {
        self.container = container
        self.trackerStore = container.trackerStore
        self.recordStore = container.recordStore
        
        let savedFilter = filterSettingsService.loadFilter()
        self.currentFilter = savedFilter
        
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
    
    func updateSearchText(_ text: String) {
        searchText = text
        isSearchActive = !text.isEmpty
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
        let categoryTitle = container.categoryStore.getCategoryTitle(for: tracker.id)
        return EditTrackerViewModel(
            tracker: tracker,
            categoryTitle: categoryTitle,
            container: container)
    }
    
    func state(for tracker: Tracker, on date: Date) -> TrackerCellState {
        let records = recordStore.records()
        
        var completedCount = 0
        var isDoneToday = false
        
        for record in records {
            guard record.trackerId == tracker.id else { continue }
            
            completedCount += 1
            
            if !isDoneToday,
               Calendar.current.isDate(record.date, inSameDayAs: date) {
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
    
    func requestDeleteTracker(at indexPath: IndexPath) {
        let tracker = sections[indexPath.section].trackers[indexPath.row]
        
        do {
            try self.container.trackerStore.delete(by: tracker.id)
            self.onChange?()
        } catch {
            assertionFailure("[TrackerListViewModel] Error message when delete fails")
        }
    }
    
    func setFilter(_ filter: FilterOption) {
        currentFilter = filter
        
        if filter == .todayTrackers {
            let today = Date()
            selectedDate = today
            onDateChangeRequested?(today)
        }
        
        reload()
        onFilterChanged?(filter)
    }
    
    func hasTrackersOnSelectedDate() -> Bool {
        let filteredByDate = filterTrackersByDate(allTrackersWithCategories)
        return !filteredByDate.isEmpty
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
        var filteredTrackers = filterTrackersByDate(allTrackersWithCategories)
        filteredTrackers = applySearchFilter(to: filteredTrackers)
        
        let filteredByOption = applyCurrentFilter(to: filteredTrackers)
        
        let newSections = buildSections(from: filteredByOption)
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
    
    private func applySearchFilter(to trackersWithCategories: [(tracker: Tracker, category: String)]) -> [(tracker: Tracker, category: String)] {
        guard !searchText.isEmpty else {
            return trackersWithCategories
        }
        
        return trackersWithCategories.filter { item in
            item.tracker.name.lowercased().contains(searchText.lowercased())
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
    
    private func applyCurrentFilter(to trackersWithCategories: [(tracker: Tracker, category: String)]) -> [(tracker: Tracker, category: String)] {
        switch currentFilter {
        case .allTrackers:
            return trackersWithCategories
            
        case .todayTrackers:
            return trackersWithCategories
            
        case .completedTrackers:
            let records = recordStore.records()
            let completedTrackerIds = records
                .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
                .map { $0.trackerId }
            
            return trackersWithCategories.filter { item in
                completedTrackerIds.contains(item.tracker.id)
            }
            
        case .notCompletedTrackers:
            let records = recordStore.records()
            let completedTrackerIds = records
                .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
                .map { $0.trackerId }
            
            return trackersWithCategories.filter { item in
                !completedTrackerIds.contains(item.tracker.id)
            }
        }
    }
    
    func getCurrentFilter() -> FilterOption {
        return currentFilter
    }
}

// MARK: - TrackerRecordFetchedResultsControllerDelegate
extension TrackerListViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChangeContent() {
        reload()
    }
}
