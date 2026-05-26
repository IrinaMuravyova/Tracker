//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 30.03.2026.
//

import UIKit

class MainTabBarController: UITabBarController {
    private let container: CoreDataContainer
    private let viewModel: TrackerListViewModel
    
    init(
        container: CoreDataContainer,
        viewModel: TrackerListViewModel
    ) {
        self.container = container
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        
        let trackerTitle = NSLocalizedString(
            "trackervc_title",
            comment: "Text displayed title for tracker view controller"
        )
        let trackersVC = TrackersViewController(
            container: container, viewModel: viewModel)
        trackersVC.tabBarItem = UITabBarItem(
            title: trackerTitle,
            image: UIImage(systemName: "record.circle.fill")?.withRenderingMode(.alwaysOriginal),
            selectedImage: nil
        )
        let trackersNavVC = UINavigationController(rootViewController: trackersVC)
        
        let statisticsTitle = NSLocalizedString(
            "statisticvc_title",
            comment: "Text displayed title for statistics view controller"
        )
        
        let service = StatisticsService(
            recordStore: container.recordStore,
            trackerStore: container.trackerStore
        )
        let viewModel = StatisticsViewModel(statisticsService: service, recordStore: container.recordStore)
        
        let statisticsVC = StatisticsViewController(
            viewModel: viewModel,
            container: container
        )
        
        statisticsVC.tabBarItem = UITabBarItem(
            title: statisticsTitle,
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
