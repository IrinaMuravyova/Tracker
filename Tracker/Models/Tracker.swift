//
//  Tracker.swift
//  Tracker
//
//  Created by Irina Muravyeva on 05.04.2026.
//
import UIKit

struct Tracker{
    let id: UUID,
        name: String,
        color: TrackerColor,
        emoji: String,
        schedule: TrackerSchedule,
        type: TrackerType
}

enum TrackerColor: String {
    case colorselection1, colorselection2, colorselection3, colorselection4, colorselection5, colorselection6, colorselection7, colorselection8, colorselection9, colorselection10, colorselection11, colorselection12,
         colorselection13, colorselection14, colorselection15,
         colorselection16, colorselection17, colorselection18
    
    var uiColor: UIColor {
        switch self {
        case .colorselection1:
            return UIColor(resource: .colorSelection1)
        case .colorselection2:
            return UIColor(resource: .colorSelection2)
        case .colorselection3:
            return UIColor(resource: .colorSelection3)
        case .colorselection4:
            return UIColor(resource: .colorSelection4)
        case .colorselection5:
            return UIColor(resource: .colorSelection5)
        case .colorselection6:
            return UIColor(resource: .colorSelection6)
        case .colorselection7:
            return UIColor(resource: .colorSelection7)
        case .colorselection8:
            return UIColor(resource: .colorSelection8)
        case .colorselection9:
            return UIColor(resource: .colorSelection9)
        case .colorselection10:
            return UIColor(resource: .colorSelection10)
        case .colorselection11:
            return UIColor(resource: .colorSelection11)
        case .colorselection12:
            return UIColor(resource: .colorSelection12)
        case .colorselection13:
            return UIColor(resource: .colorSelection13)
        case .colorselection14:
            return UIColor(resource: .colorSelection14)
        case .colorselection15:
            return UIColor(resource: .colorSelection15)
        case .colorselection16:
            return UIColor(resource: .colorSelection16)
        case .colorselection17:
            return UIColor(resource: .colorSelection17)
        case .colorselection18:
            return UIColor(resource: .colorSelection18)
        }
    }
}

enum TrackerSchedule {
    case daysOfWeek(Set<Weekday>)
}

enum Weekday: Int, CaseIterable {
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

enum TrackerType: String {
    case habit
    case irregular
}
