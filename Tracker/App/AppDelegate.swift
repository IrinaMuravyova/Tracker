//
//  AppDelegate.swift
//  Tracker
//
//  Created by Irina Muravyeva on 26.03.2026.
//

import UIKit
import AppMetricaCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let configuration = AppMetricaConfiguration(apiKey: "adf35b6d-b7e4-4a5c-a251-a6dcc5e25f4f") {
            AppMetrica.activate(with: configuration)
        }
            
        return true
    }
}

