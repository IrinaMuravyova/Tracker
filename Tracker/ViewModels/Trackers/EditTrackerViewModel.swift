//
//  EditTrackerViewModel.swift
//  Tracker
//
//  Created by Irina Muravyeva on 23.05.2026.
//

import Foundation

final class EditTrackerViewModel: TrackerViewModel {
    private let trackerID: UUID
    
    init(
        tracker: Tracker,
        categoryTitle: String,
        container: CoreDataContainer
    ) {
        self.trackerID = tracker.id
        super.init( trackerType: tracker.type, container: container )
        
        title = tracker.name
        category = categoryTitle
        
        switch tracker.schedule {
            case .daysOfWeek(let days):
                schedule = days
        }
        
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
    }
    
    override var screenTitle: String {
        NSLocalizedString( "edit_tracker_title", comment: "" )
    }

    override func saveTracker() {
        do {
            try container.trackerStore.updateTracker(
                id: trackerID,
                title: title,
                category: category,
                schedule: schedule,
                emoji: selectedEmoji ?? "",
                color: selectedColor ?? .colorselection1
            )
            onTrackerSaved?()
        } catch {
            print(error)
        }
    }
    
    override func makeCategoriesViewModel(mode: CategoriesViewMode) -> CategoriesViewModel {
        let vm = CategoriesViewModel(categoryStore: container.categoryStore)
        vm.setSelectedCategory(category)
        return vm
    }
}
