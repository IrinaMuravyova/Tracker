//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Irina Muravyeva on 26.05.2026.
//

import Foundation

class StatisticsViewModel: NSObject {
    // MARK: - Properties
    var items: Observable<[StatisticsItem]> = Observable([])
    var isEmpty: Observable<Bool> = Observable(true)
    
    private let statisticsService: StatisticsService
    private let recordStore: TrackerRecordStore
    
    // MARK: - Init
    init(statisticsService: StatisticsService, recordStore: TrackerRecordStore) {
        self.statisticsService = statisticsService
        self.recordStore = recordStore
        super.init()
        
        recordStore.delegate = self
        
        updateStatistics()
    }
    
    // MARK: - Public methods
    func updateStatistics() {
        guard statisticsService.hasAnyRecords() else {
            items.value = []
            isEmpty.value = true
            return
        }
        
        let bestPeriod = statisticsService.getBestPeriod()
        let idealDays = statisticsService.getIdealDays()
        let completed = statisticsService.getTotalCompletedCount()
        let average = statisticsService.getAverageValue()
        
        let statistics = [
            StatisticsItem(
                title: NSLocalizedString("bestPeriod", comment: "The best period of complete tracker"),
                value: bestPeriod
            ),
            StatisticsItem(
                title: NSLocalizedString("idealDays", comment: "Count of days when all trackers were completed"),
                value: idealDays
            ),
            StatisticsItem(
                title: NSLocalizedString("completed", comment: "Count of completed trackers"),
                value: completed
            ),
            StatisticsItem(
                title: NSLocalizedString("average", comment: "Average"),
                value: average
            )
        ]
        
        items.value = statistics
        isEmpty.value = false
    }
}

// MARK: - TrackerRecordStoreDelegate
extension StatisticsViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChangeContent() {
        updateStatistics()
    }
}
