//
//  TrackerUIModel.swift
//  Tracker
//
//  Created by Irina Muravyeva on 06.05.2026.
//

import Foundation

struct TrackerUIModel {
    let id: UUID
    let name: String
    let emoji: String
    let color: TrackerColor

    let completedCount: Int
    let isDoneToday: Bool
    
    let isPinned: Bool
}
