//
//              TrackerScheduleTransformer.swift
//  Tracker
//
//  Created by Irina Muravyeva on 24.04.2026.
//

import Foundation

@objc(TrackerScheduleTransformer)
final class TrackerScheduleTransformer: ValueTransformer {
    static func register() {
        ValueTransformer.setValueTransformer(
            TrackerScheduleTransformer(),
            forName: NSValueTransformerName("TrackerScheduleTransformer")
        )
    }
    
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let schedule = value as? TrackerSchedule else { return nil }
        return try? JSONEncoder().encode(schedule) as NSData
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode(TrackerSchedule.self, from: data as Data)
    }
}
