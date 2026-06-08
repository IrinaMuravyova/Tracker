//
//  Weekday.swift
//  Tracker
//
//  Created by Irina Muravyeva on 15.04.2026.
//

import Foundation

enum Weekday: Int, CaseIterable, Codable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var title: String {
        switch self {
        case .monday:
            return NSLocalizedString(
                "weekday_monday",
                comment: "Monday short title"
            )
        case .tuesday: 
            return NSLocalizedString(
                "weekday_tuesday",
                comment: "Tuesday short title"
            )
        case .wednesday: 
            return NSLocalizedString(
                "weekday_wednesday",
                comment: "Wednesday short title"
            )
        case .thursday: 
            return NSLocalizedString(
                "weekday_thursday",
                comment: "Thursday short title"
            )
        case .friday: 
            return NSLocalizedString(
                "weekday_friday",
                comment: "Friday short title"
            )
        case .saturday: 
            return NSLocalizedString(
                "weekday_saturday",
                comment: "Saturday short title"
            )
        case .sunday: 
            return NSLocalizedString(
                "weekday_sunday",
                comment: "Sunday short title"
            )
        }
    }

    var shortTitle: String {
        switch self {
        case .monday: 
            return NSLocalizedString(
                "weekday_short_monday",
                comment: "Monday short title"
            )
        case .tuesday:
            return NSLocalizedString(
                "weekday_short_tuesday",
                comment: "Tuesday short title"
            )
        case .wednesday:
            return NSLocalizedString(
                "weekday_short_wednesday",
                comment: "Wednesday short title"
            )
        case .thursday:
            return NSLocalizedString(
                "weekday_short_thursday",
                comment: "Thursday short title"
            )
        case .friday:
            return NSLocalizedString(
                "weekday_short_friday",
                comment: "Friday short title"
            )
        case .saturday:
            return NSLocalizedString(
                "weekday_short_saturday",
                comment: "Saturday short title"
            )
        case .sunday:
            return NSLocalizedString(
                "weekday_short_sunday",
                comment: "Sunday short title"
            )
        }
    }
}

// MARK: - Extension for filtering on date
extension Weekday {
    init?(calendarWeekday: Int) {
        let normalized = calendarWeekday == 1 ? 7 : calendarWeekday - 1
        self.init(rawValue: normalized)
    }
}
