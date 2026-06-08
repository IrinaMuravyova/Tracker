//
//  FilterSettingsService.swift
//  Tracker
//
//  Created by Irina Muravyeva on 26.05.2026.
//

import Foundation

final class FilterSettingsService {
    private let userDefaults = UserDefaults.standard
    private let filterKey = "selected_filter"
    
    func saveFilter(_ filter: FilterOption) {
        userDefaults.set(filter.rawValue, forKey: filterKey)
    }
    
    func loadFilter() -> FilterOption {
        guard let filterRawValue = userDefaults.string(forKey: filterKey),
              let filter = FilterOption(rawValue: filterRawValue) else {
            return .allTrackers
        }
        return filter
    }
}
