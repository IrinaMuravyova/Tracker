//
//  StatisticsService.swift
//  Tracker
//
//  Created by Irina Muravyeva on 26.05.2026.
//

import Foundation

class StatisticsService {
    private let recordStore: TrackerRecordStore
    private let trackerStore: TrackerStore
    
    init(recordStore: TrackerRecordStore, trackerStore: TrackerStore) {
        self.recordStore = recordStore
        self.trackerStore = trackerStore
    }
    
    func hasAnyRecords() -> Bool {
        return recordStore.records().count > 0
    }
    
    func getTotalCompletedCount() -> Int {
        return recordStore.records().count
    }
    
    func getBestPeriod() -> Int {
        let records = recordStore.records()
        var countPerDay: [Date: Int] = [:]
        
        for record in records {
            let day = Calendar.current.startOfDay(for: record.date)
            countPerDay[day] = (countPerDay[day] ?? 0) + 1
        }
        
        return countPerDay.values.max() ?? 0
    }
    
    func getIdealDays() -> Int {
        let records = recordStore.records()
        var countPerDay: [Date: Int] = [:]
        
        for record in records {
            let day = Calendar.current.startOfDay(for: record.date)
            countPerDay[day] = (countPerDay[day] ?? 0) + 1
        }
        
        guard let maxCount = countPerDay.values.max() else { return 0 }
        
        let idealDays = countPerDay.values.filter { $0 == maxCount }.count
        
        return idealDays
    }
    
    func getAverageValue() -> Int {
        let records = recordStore.records()
        var countPerDay: [Date: Int] = [:]
        
        for record in records {
            let day = Calendar.current.startOfDay(for: record.date)
            countPerDay[day] = (countPerDay[day] ?? 0) + 1
        }
        
        guard countPerDay.count > 0 else { return 0 }
        
        let total = countPerDay.values.reduce(0, +)
        return total / countPerDay.count
    }
}
