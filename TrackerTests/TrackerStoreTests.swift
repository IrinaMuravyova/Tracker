//
//  TrackerStoreTests.swift
//  TrackerTests
//
//  Created by Irina Muravyeva on 06.05.2026.
//

import XCTest
@testable import Tracker

final class TrackerStoreTest: XCTestCase {
    func testTrackerSaving() throws {

        // Arrange
        let container = CoreDataContainer(inMemory: true)
        let repository = MockTrackerRepository()
        let store = TrackerStore(repository: repository)

        try repository.addCategory("Health")

        let tracker = Tracker(
            id: UUID(),
            name: "Test",
            color: .colorselection1,
            emoji: "🔥",
            schedule: .daysOfWeek([.monday, .tuesday]),
            type: .habit
        )

        // Act
        try store.add(tracker, to: "Health")
        let result = try store.fetchAllTrackers()

        // Assert
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Test")
        XCTAssertEqual(result.first?.emoji, "🔥")
    }
}
