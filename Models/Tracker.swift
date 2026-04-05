//
//  Tracker.swift
//  Tracker
//
//  Created by Irina Muravyeva on 05.04.2026.
//
import Foundation

struct Tracker {
    let id: UUID,
        name: String,
        color: TrackerColor,
        emoji: String,
        schedule: [TrackerSchedule],
        type: TrackerType
}

enum TrackerColor {
    case red, green, blue, yellow, purple, orange, pink, brown, black, white
}

enum TrackerSchedule {
    case daysOfWeek(Set<Weekday>)
}

enum Weekday: Int {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

enum TrackerType: String {
    case habit
    case irregular
}
