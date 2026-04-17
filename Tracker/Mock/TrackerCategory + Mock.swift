//
//  TrackerCategory + Mock.swift
//  Tracker
//
//  Created by Irina Muravyeva on 15.04.2026.
//

import Foundation

extension TrackerCategory {
    static func mock(trackers: [Tracker]) -> [TrackerCategory] {
        [
            TrackerCategory(title: "Важное", trackers: [trackers[4]]),
            TrackerCategory(title: "Домашний уют", trackers: [trackers[0]]),
            TrackerCategory(title: "Радостные мелочи", trackers: [trackers[1], trackers[2], trackers[3]])
        ]
    }
}
