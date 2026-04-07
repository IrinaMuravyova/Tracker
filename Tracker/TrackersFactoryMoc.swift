//
//  TrackersFactoryMoc.swift
//  Tracker
//
//  Created by Irina Muravyeva on 06.04.2026.
//

import UIKit

class TrackersFactoryMoc {
    private let trackersId: [UUID] = [UUID(), UUID(), UUID(), UUID()]
    private var trackers: [Tracker] = []
    private lazy var trackerCategory: [TrackerCategory] = [
        TrackerCategory(title: "Домашний уют", trackers: [trackers[0]]),
        TrackerCategory(title: "Радостные мелочи", trackers: [trackers[1], trackers[2], trackers[3]])
    ]
    
    init() {
        trackers = [
            Tracker(
                id: trackersId[0],
                name: "Поливать растение",
                color: .colorselection5,
                emoji: "❤️",
                schedule: [],
                type: .habit
            ),
            Tracker(
                id: trackersId[1],
                name: "Кошка заслонила камеру на созвоне",
                color: .colorselection2,
                emoji: "😻",
                schedule: [],
                type: .habit
            ),
            Tracker(
                id: trackersId[2],
                name: "Бабушка прислала открытку в ватсапе",
                color: .colorselection1,
                emoji: "🌺",
                schedule: [],
                type: .habit
            ),
            Tracker(
                id: trackersId[3],
                name: "Свидание в апреле",
                color: .colorselection14,
                emoji: "❤️",
                schedule: [],
                type: .habit
            ),
        ]
    }
    
    func getTrackersCategory() -> [TrackerCategory] {
        trackerCategory
    }
    
    func getCompletedTrackers() -> [TrackerRecord] {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            return []
        }
        
        return [
            TrackerRecord(trackerId: trackersId[0], date: yesterday),
            TrackerRecord(trackerId: trackersId[1], date: yesterday),
            TrackerRecord(trackerId: trackersId[1], date: yesterday),
            TrackerRecord(trackerId: trackersId[1], date: yesterday),
            TrackerRecord(trackerId: trackersId[1], date: yesterday),
            TrackerRecord(trackerId: trackersId[1], date: yesterday),
            TrackerRecord(trackerId: trackersId[2], date: yesterday),
            TrackerRecord(trackerId: trackersId[2], date: yesterday),
            TrackerRecord(trackerId: trackersId[2], date: yesterday),
            TrackerRecord(trackerId: trackersId[2], date: yesterday),
            TrackerRecord(trackerId: trackersId[3], date: yesterday),
            TrackerRecord(trackerId: trackersId[3], date: yesterday),
            TrackerRecord(trackerId: trackersId[3], date: yesterday),
            TrackerRecord(trackerId: trackersId[3], date: yesterday),
            TrackerRecord(trackerId: trackersId[3], date: yesterday),
        ]
    }
}
