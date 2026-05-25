//
//  TrackerViewModel.swift
//  Tracker
//
//  Created by Irina Muravyeva on 24.05.2026.
//

import Foundation

protocol TrackerViewModelProtocol: AnyObject {
    // MARK: - Bindings
    var onSaveButtonStateChanged: ((Bool) -> Void)? { get set }
    var onCategoryChanged: ((String) -> Void)? { get set }
    var onScheduleChanged: ((String) -> Void)? { get set }
    var onTrackerSaved: (() -> Void)? { get set }

    // MARK: - Output Properties
    var screenTitle: String { get }
    var isHabit: Bool { get }
    var title: String { get set }
    var category: String { get set }
    var schedule: Set<Weekday> { get set }
    var selectedEmoji: String? { get set }
    var selectedColor: TrackerColor? { get set }

    var scheduleText: String { get }
    
    // MARK: - Input
    func updateTitle(_ text: String)
    func updateCategory(_ category: String)
    func updateSchedule(_ days: Set<Weekday>)
    func updateEmoji(_ emoji: String)
    func updateColor(_ color: TrackerColor)

    // MARK: - Actions
    func saveTracker()
    func makeCategoriesViewModel() -> CategoriesViewModel
    func validate()
}

class TrackerViewModel: TrackerViewModelProtocol {
    // MARK: - Input state
    var title: String = ""
    var category: String = ""
    var schedule: Set<Weekday> = []

    var selectedEmoji: String?
    var selectedColor: TrackerColor?

    // MARK: - Dependencies
    let trackerType: TrackerType
    let container: CoreDataContainer

    // MARK: - Bindings
    var onSaveButtonStateChanged: ((Bool) -> Void)?
    var onCategoryChanged: ((String) -> Void)?
    var onScheduleChanged: ((String) -> Void)?
    var onTrackerSaved: (() -> Void)?

    // MARK: - Init
    init(
        trackerType: TrackerType,
        container: CoreDataContainer
    ) {
        self.trackerType = trackerType
        self.container = container
    }

    // MARK: - Output
    var isHabit: Bool {
        trackerType == .habit
    }

    var screenTitle: String {
        fatalError("Override in subclass")
    }

    // MARK: - Input updates
    func updateTitle(_ text: String) {
        title = text
        validate()
    }

    func updateCategory(_ category: String) {
        self.category = category

        onCategoryChanged?(category)

        validate()
    }

    func updateSchedule(_ days: Set<Weekday>) {
        schedule = days

        onScheduleChanged?(scheduleText)

        validate()
    }

    func updateEmoji(_ emoji: String) {
        selectedEmoji = emoji
        validate()
    }

    func updateColor(_ color: TrackerColor) {
        selectedColor = color
        validate()
    }
    
    // MARK: - Actions
    func saveTracker() {
        fatalError("Override in subclass")
    }

    func makeCategoriesViewModel() -> CategoriesViewModel {
        CategoriesViewModel(categoryStore: container.categoryStore)
    }
}

extension TrackerViewModel {

    var scheduleText: String {

        if schedule.count == Weekday.allCases.count {
            return NSLocalizedString(
                "days_string_text",
                comment: ""
            )
        }

        return schedule
            .sorted(by: { $0.rawValue < $1.rawValue })
            .map(\.shortTitle)
            .joined(separator: ", ")
    }

    func validate() {

        let isValid: Bool

        if isHabit {
            isValid =
            !title.isEmpty &&
            !category.isEmpty &&
            !schedule.isEmpty &&
            selectedEmoji != nil &&
            selectedColor != nil
        } else {
            isValid =
            !title.isEmpty &&
            !category.isEmpty &&
            selectedEmoji != nil &&
            selectedColor != nil
        }

        onSaveButtonStateChanged?(isValid)
    }
}
