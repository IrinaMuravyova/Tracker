//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 30.03.2026.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        
        let trackersVC = TrackersViewController()
        trackersVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
            )
        let trackersNavVC = UINavigationController(rootViewController: trackersVC)
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        let statisticsNavVC = UINavigationController(rootViewController: statisticsVC)
        
        viewControllers = [trackersNavVC, statisticsNavVC]
    }
}
