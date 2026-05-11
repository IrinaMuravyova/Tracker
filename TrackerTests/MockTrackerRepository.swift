//
//  MockTrackerRepository.swift
//  TrackerTests
//
//  Created by Irina Muravyeva on 11.05.2026.
//

import Foundation
@testable import Tracker

final class MockTrackerRepository: TrackerRepository {

    private var trackers: [Tracker] = []
    private var categories: Set<String> = []

    func addCategory(_ title: String) throws {
        categories.insert(title)
    }

    func add(_ tracker: Tracker, to category: String) throws {
        guard categories.contains(category) else {
            throw NSError(domain: "Category not found", code: 1)
        }

        trackers.append(tracker)
    }

    func fetchAll() throws -> [Tracker] {
        trackers
    }
}
