//
//  TrackerColor.swift
//  Tracker
//
//  Created by Irina Muravyeva on 15.04.2026.
//

import UIKit

enum TrackerColor: String, CaseIterable {
    case colorselection1, colorselection2, colorselection3, colorselection4, colorselection5, colorselection6, colorselection7, colorselection8, colorselection9, colorselection10, colorselection11, colorselection12,
         colorselection13, colorselection14, colorselection15,
         colorselection16, colorselection17, colorselection18
    
    var uiColor: UIColor {
        switch self {
        case .colorselection1:
            return UIColor(resource: .colorSelection1)
        case .colorselection2:
            return UIColor(resource: .colorSelection2)
        case .colorselection3:
            return UIColor(resource: .colorSelection3)
        case .colorselection4:
            return UIColor(resource: .colorSelection4)
        case .colorselection5:
            return UIColor(resource: .colorSelection5)
        case .colorselection6:
            return UIColor(resource: .colorSelection6)
        case .colorselection7:
            return UIColor(resource: .colorSelection7)
        case .colorselection8:
            return UIColor(resource: .colorSelection8)
        case .colorselection9:
            return UIColor(resource: .colorSelection9)
        case .colorselection10:
            return UIColor(resource: .colorSelection10)
        case .colorselection11:
            return UIColor(resource: .colorSelection11)
        case .colorselection12:
            return UIColor(resource: .colorSelection12)
        case .colorselection13:
            return UIColor(resource: .colorSelection13)
        case .colorselection14:
            return UIColor(resource: .colorSelection14)
        case .colorselection15:
            return UIColor(resource: .colorSelection15)
        case .colorselection16:
            return UIColor(resource: .colorSelection16)
        case .colorselection17:
            return UIColor(resource: .colorSelection17)
        case .colorselection18:
            return UIColor(resource: .colorSelection18)
        }
    }
}

// MARK: - Mapping for TrackerCoreData.color
extension TrackerColor {
    static func from(_ raw: String?) -> TrackerColor {
        guard
            let raw,
            let color = TrackerColor(rawValue: raw)
        else {
            return .colorselection1
        }
        return color
    }
}
