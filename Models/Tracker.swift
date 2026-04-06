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
    case colorselection1, colorselection2, colorselection3, colorselection4, colorselection5, colorselection6, colorselection7, colorselection8, colorselection9, colorselection10, colorselection11, colorselection12,
         colorselection13, colorselection14, colorselection15,
         colorselection16, colorselection17, colorselection18
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
