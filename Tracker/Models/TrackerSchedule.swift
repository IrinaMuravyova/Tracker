//
//  TrackerSchedule.swift
//  Tracker
//
//  Created by Irina Muravyeva on 15.04.2026.
//

import Foundation

enum TrackerSchedule: Codable {
    case daysOfWeek(Set<Weekday>)
    
    enum CodingKeys: String, CodingKey {
        case type
        case days
    }
    
    enum Kind: String, Codable {
        case daysOfWeek
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .daysOfWeek(let days):
            try container.encode(Kind.daysOfWeek, forKey: .type)
            try container.encode(days.map { $0.rawValue }, forKey: .days)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(Kind.self, forKey: .type)
        
        switch type {
        case .daysOfWeek:
            let raw = try container.decode([Int].self, forKey: .days)
            let days = Set(raw.compactMap(Weekday.init(rawValue:)))
            self = .daysOfWeek(days)
        }
    }
}
