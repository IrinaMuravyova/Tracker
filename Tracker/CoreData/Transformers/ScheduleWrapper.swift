//
//  ScheduleWrapper.swift
//  Tracker
//
//  Created by Irina Muravyeva on 27.04.2026.
//

import Foundation

@objc class ScheduleWrapper: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    let schedule: TrackerSchedule
    
    init(_ schedule: TrackerSchedule) {
        self.schedule = schedule
    }
    
    func encode(with coder: NSCoder) {
        let data = try? JSONEncoder().encode(schedule)
        coder.encode(data, forKey: "schedule")
    }
    
    required init?(coder: NSCoder) {
        guard let data = coder.decodeObject(forKey: "schedule") as? Data,
              let schedule = try? JSONDecoder().decode(TrackerSchedule.self, from: data) else {
            return nil
        }
        self.schedule = schedule
    }
}
