//
//  FilterOption.swift
//  Tracker
//
//  Created by Irina Muravyeva on 26.05.2026.
//

import Foundation

enum FilterOption: String, CaseIterable {
    case allTrackers
    case todayTrackers
    case completedTrackers
    case notCompletedTrackers
    
    var localizedTitle: String {
        return NSLocalizedString(self.rawValue, comment: "Filter option title")
    }
}
