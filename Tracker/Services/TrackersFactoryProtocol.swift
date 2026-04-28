//
//  TrackersFactoryProtocol.swift
//  Tracker
//
//  Created by Irina Muravyeva on 13.04.2026.
//

import Foundation

protocol TrackersFactoryProtocol: AnyObject {
    func getTrackersCategory() -> [TrackerCategory]
    func getCompletedTrackers() -> [TrackerRecord]
    func trackerRecordsDidUpdated(with record: TrackerRecord)
    func trackerRecordDidCanceled(for trackerId: UUID, at data: Date)
    func trackerDidAdd(_ tracker: Tracker,  category: String)
    func addCategory(_ title: String)
}
