//
//  Date + Weekdays.swift
//  Tracker
//
//  Created by Irina Muravyeva on 15.04.2026.
//

import Foundation

extension Date {
    func weekday() -> Weekday {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: self)
        let mappedValue = weekdayNumber == 1 ? 7 : weekdayNumber - 1
        return Weekday(rawValue: mappedValue)!
    }
}
