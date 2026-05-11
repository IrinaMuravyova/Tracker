//
//  TrackerRepository.swift
//  TrackerTests
//
//  Created by Irina Muravyeva on 11.05.2026.
//

import Foundation
@testable import Tracker

protocol TrackerRepository {
    func add(_ tracker: Tracker, to category: String) throws
    func fetchAll() throws -> [Tracker]
    func addCategory(_ title: String) throws
}
