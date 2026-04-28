//
//  TrackerSchedule.swift
//  Tracker
//
//  Created by Irina Muravyeva on 15.04.2026.
//

import Foundation

enum TrackerSchedule: Codable {
    case daysOfWeek(Set<Weekday>)
}
