//
//  TrackersFactory.swift
//  Tracker
//
//  Created by Irina Muravyeva on 06.04.2026.
//

import UIKit

class TrackersFactory {
    static let shared = TrackersFactory()
    private let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    private var trackersId: [UUID] = []
    private var trackers: [Tracker] = []
    private var trackerCategory: [TrackerCategory] = []
    private var trackersRecords: [TrackerRecord] = []
    
    private init () {
        setId()
        self.trackers = [
            Tracker(
                id: trackersId[0],
                name: "Поливать растение",
                color: .colorselection5,
                emoji: "❤️",
                schedule: TrackerSchedule.daysOfWeek([.monday]),
                type: .habit
            ),
            Tracker(
                id: trackersId[1],
                name: "Кошка заслонила камеру на созвоне",
                color: .colorselection2,
                emoji: "😻",
                schedule: TrackerSchedule.daysOfWeek([.tuesday]),
                type: .habit
            ),
            Tracker(
                id: trackersId[2],
                name: "Бабушка прислала открытку в ватсапе",
                color: .colorselection1,
                emoji: "🌺",
                schedule: TrackerSchedule.daysOfWeek([.monday, .thursday]),
                type: .habit
            ),
            Tracker(
                id: trackersId[3],
                name: "Свидание в апреле",
                color: .colorselection14,
                emoji: "❤️",
                schedule: TrackerSchedule.daysOfWeek([.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]),
                type: .habit
            )
        ]
        
        trackerCategory = [
            TrackerCategory(title: "Важное", trackers: []),
            TrackerCategory(title: "Домашний уют", trackers: [trackers[0]]),
            TrackerCategory(title: "Радостные мелочи", trackers: [trackers[1], trackers[2], trackers[3]])
        ]
        
        trackersRecords = [
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
    
    private func setId() {
        self.trackersId = [
        UUID(uuidString: "F8A3AFEF-0D47-4EBF-8070-D8DC1D119D04")!,
        UUID(uuidString: "107C3003-CAC0-4299-B468-B05AB3F6675D")!,
        UUID(uuidString: "7C072853-EF2D-4EF0-A10D-6EE73339CDC8")!,
        UUID(uuidString:"CD4E5590-C456-4ABB-91BA-C95D76250DE5")!
        ]
    }

    // MARK: - Public functions
    func getTrackersCategory() -> [TrackerCategory] {
        return trackerCategory
    }
    
    func getCompletedTrackers() -> [TrackerRecord] {
        return trackersRecords
    }
}

extension TrackersFactory {
    func trackerRecordsDidUpdated(with record: TrackerRecord) {
        self.trackersRecords.append(record)
    }
    
    func trackerRecordDidCanceled(for trackerId: UUID, at data: Date) {
        
        let index = self.trackersRecords.firstIndex(where: {
            $0.trackerId == trackerId
            && Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for: data)
        })
        
        guard let index else { return }
        self.trackersRecords.remove(at: index)
    }
    
    func trackerDidAdd(_ tracker: Tracker,  category: String) {
        if let index = trackerCategory.firstIndex(where: {$0.title == category}) {
            self.trackerCategory[index].trackers.append(tracker)
            self.trackers.append(tracker)
            
        } else {
            let newCategory = TrackerCategory(
                title: category,
                trackers: [tracker]
            )
            self.trackerCategory.append(newCategory)
        }
    }
}
