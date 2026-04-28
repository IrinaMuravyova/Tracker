//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 30.03.2026.
//

import UIKit

class MainTabBarController: UITabBarController {
//    private let trackerStore: TrackerStore
//    private let recordStore: TrackerRecordStore
//    private let categoryStore: TrackerCategoryStore
    private let container: CoreDataContainer
    
    init(
        container: CoreDataContainer
//        trackerStore: TrackerStore,
//        recordStore: TrackerRecordStore,
//        categoryStore: TrackerCategoryStore
    ) {
        self.container = container
//        self.trackerStore = trackerStore
//        self.recordStore = recordStore
//        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        
//        let trackersVC = TrackersViewController()
        let trackersVC = TrackersViewController(
            container: container)
//            trackerStore: container.trackerStore,
//            trackerRecordStore: container.recordStore)
        trackersVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill")?.withRenderingMode(.alwaysOriginal),
            selectedImage: nil
        )
        let trackersNavVC = UINavigationController(rootViewController: trackersVC)
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill")?.withRenderingMode(.alwaysOriginal),
            selectedImage: nil
        )
        let statisticsNavVC = UINavigationController(rootViewController: statisticsVC)
        
        viewControllers = [trackersNavVC, statisticsNavVC]
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .white
        
        // icon
        appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.onTintSwitch,
        ]
        
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray
        ]
        
        // text
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray
        ]
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
