//
//  TrackerStore.swift
//  TrackerTests
//
//  Created by Irina Muravyeva on 11.05.2026.
//

import Foundation
@testable import Tracker

final class TrackerStore {

    private let repository: TrackerRepository

    init(repository: TrackerRepository) {
        self.repository = repository
    }

    func add(_ tracker: Tracker, to category: String) throws {
        try repository.add(tracker, to: category)
    }

    func fetchAllTrackers() throws -> [Tracker] {
        try repository.fetchAll()
    }
}
