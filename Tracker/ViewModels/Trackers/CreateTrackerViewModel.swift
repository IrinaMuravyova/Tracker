//
//  CreateTrackerViewModel.swift
//  Tracker
//
//  Created by Irina Muravyeva on 24.05.2026.
//

import Foundation

final class CreateTrackerViewModel: TrackerViewModel {
    let viewModel: TrackerViewModel
    
    override var screenTitle: String {

        trackerType == .habit
        ? NSLocalizedString(
            "create_habit_title",
            comment: ""
        )
        : NSLocalizedString(
            "create_event_title",
            comment: ""
        )
    }

    override func saveTracker() {

        let tracker = Tracker(
            id: UUID(),
            name: title,
            color: selectedColor ?? .colorselection1,
            emoji: selectedEmoji ?? "",
            schedule: TrackerSchedule.daysOfWeek(schedule),
            type: trackerType
        )

        do {

            try container.trackerStore.add(
                tracker,
                to: category
            )

            onTrackerSaved?()

        } catch {

            print(error)
        }
    }
    
    init(viewModel: TrackerViewModel) {
        self.viewModel = viewModel
       
        super.init(
            trackerType: viewModel.trackerType,
            container: viewModel.container
        )
    }
}
