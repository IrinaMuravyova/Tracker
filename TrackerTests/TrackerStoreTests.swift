//
//  TrackerStoreTests.swift
//  TrackerTests
//
//  Created by Irina Muravyeva on 06.05.2026.
//

import XCTest
@testable import Tracker
import CoreData

final class TrackerStoreTest: XCTestCase {

    func testTrackerSaving() throws {
        let context = inMemoryContext
        
        let categoryStore = TrackerCategoryStore(context: context)
        try categoryStore.addCategory("Health")
        
        let trackerStore = TrackerStore(context: context)
        
        let tracker = Tracker(
            id: UUID(),
            name: "Test",
            color: .colorselection1,
            emoji: "🔥",
            schedule: .daysOfWeek([.monday, .tuesday]),
            type: .habit
        )
        
        try trackerStore.add(tracker, to: "Health")
        
        let result = try trackerStore.fetchAllTrackers()

        XCTAssertEqual(result.count, 1)
        
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let objects = try context.fetch(request)
                
        XCTAssertNotNil(objects.first?.category)
        XCTAssertEqual(objects.first?.category?.title, "Health")
        
        let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let categories = try context.fetch(categoryRequest)

        XCTAssertEqual(categories.first?.tracker?.count, 1)
    }
}
