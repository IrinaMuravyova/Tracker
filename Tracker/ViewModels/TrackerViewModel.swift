//
//  TrackerViewModel.swift
//  Tracker
//
//  Created by Irina Muravyeva on 06.05.2026.
//

import Foundation

struct TrackerViewModel {
    let id: UUID
    let name: String
    let emoji: String
    let color: TrackerColor

    let completedCount: Int
    let isDoneToday: Bool
}
