////
////  TrackersFactory.swift
////  Tracker
////
////  Created by Irina Muravyeva on 06.04.2026.
////
//
//import UIKit
//
//class TrackersFactory {
//    // MARK: - Static properties
//    static let shared = TrackersFactory()
//    
//    // MARK: - Private properties
//    private let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
//    private var trackersId: [UUID] = []
//    private var trackers: [Tracker] = []
//    private var trackerCategory: [TrackerCategory] = []
//    private var trackersRecords: [TrackerRecord] = []
//    
//    // MARK: - Initializes
//    private init () {
//        self.trackersId = Tracker.mockId()
//        self.trackers = Tracker.mock(trackersId: trackersId)
//        self.trackerCategory = TrackerCategory.mock(trackers: trackers)
//        self.trackersRecords = TrackerRecord.mock(trackersId: trackersId, date: yesterday)
//    }
//}
//
//// MARK: - TrackersFactoryProtocol
//extension TrackersFactory: TrackersFactoryProtocol {
//    func getTrackersCategory() -> [TrackerCategory] {
//        return trackerCategory
//    }
//    
//    func getCompletedTrackers() -> [TrackerRecord] {
//        return trackersRecords
//    }
//    
//    func trackerRecordsDidUpdated(with record: TrackerRecord) {
//        self.trackersRecords.append(record)
//    }
//    
//    func trackerRecordDidCanceled(for trackerId: UUID, at data: Date) {
//        
//        let index = self.trackersRecords.firstIndex(where: {
//            $0.trackerId == trackerId
//            && Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for: data)
//        })
//        
//        guard let index else { return }
//        self.trackersRecords.remove(at: index)
//    }
//    
//    func trackerDidAdd(_ tracker: Tracker,  category: String) {
//        if let index = trackerCategory.firstIndex(where: {$0.title == category}) {
//            trackerCategory = trackerCategory.enumerated().map { i, cat in
//                i == index ? cat.addingTracker(tracker) : cat
//            }
//        } else {
//            trackerCategory = trackerCategory + [
//                TrackerCategory(title: category, trackers: [tracker])
//            ]
//        }
//        trackers.append(tracker)
//    }
//    
//    func addCategory(_ title: String) {
//        trackerCategory.append(TrackerCategory(title: title, trackers: []))
//    }
//}
