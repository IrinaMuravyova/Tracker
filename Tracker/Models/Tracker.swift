//
//  Tracker.swift
//  Tracker
//
//  Created by Irina Muravyeva on 05.04.2026.
//
import UIKit

struct Tracker{
    let id: UUID,
        name: String,
        color: TrackerColor,
        emoji: String,
        schedule: TrackerSchedule,
        type: TrackerType,
        isPinned: Bool = false
}
