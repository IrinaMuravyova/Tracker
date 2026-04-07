//
//  TrackersFactoryMoc.swift
//  Tracker
//
//  Created by Irina Muravyeva on 06.04.2026.
//

import UIKit

class TrackersFactoryMoc {
    private let trackers: [Tracker] = [
        Tracker(
            id: UUID(),
            name: "Поливать растение",
            color: .colorselection5,
            emoji: "❤️",
            schedule: [],
            type: .habit
        ),
        Tracker(
            id: UUID(),
            name: "Кошка заслонила камеру на созвоне",
            color: .colorselection2,
            emoji: "😻",
            schedule: [],
            type: .habit
        ),
        Tracker(
            id: UUID(),
            name: "Бабушка прислала открытку в ватсапе",
            color: .colorselection1,
            emoji: "🌺",
            schedule: [],
            type: .habit
        ),
        Tracker(
            id: UUID(),
            name: "Свидание в апреле",
            color: .colorselection14,
            emoji: "❤️",
            schedule: [],
            type: .habit
        ),
    ]
    
    private lazy var trackerCategory: [TrackerCategory] = [
        TrackerCategory(title: "Домашний уют", trackers: [trackers[0]]),
        TrackerCategory(title: "Радостные мелочи", trackers: [trackers[1], trackers[2], trackers[3]])
    ]
    
    func getTrackersCategory() -> [TrackerCategory] {
        trackerCategory
    }
}
