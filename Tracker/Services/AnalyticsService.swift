//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Irina Muravyeva on 26.05.2026.
//

import Foundation
import AppMetricaCore

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    func sendEvent(event: String, screen: String, item: String? = nil) {
        var parameters: [String: Any] = [
            "event": event,
            "screen": screen
        ]
        
        if let item = item {
            parameters["item"] = item
        }
        
        AppMetrica.reportEvent(name: "user_action", parameters: parameters)
        
        print("[ANALYTICS] Event: \(event), Screen: \(screen), Item: \(item ?? "nil")")
    }
}
