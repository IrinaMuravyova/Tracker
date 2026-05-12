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
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }

    var shortTitle: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
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
