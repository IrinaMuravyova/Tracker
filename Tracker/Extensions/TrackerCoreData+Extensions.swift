//
//  TrackerCoreData+Extensions.swift
//  Tracker
//
//  Created by Irina Muravyeva on 23.05.2026.
//

import CoreData

extension TrackerCoreData {

    @objc var sectionName: String {
        isPinned ? "Закреплённые" : (category?.title ?? "")
    }
}
