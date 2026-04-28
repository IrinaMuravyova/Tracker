//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Irina Muravyeva on 26.03.2026.
//

import UIKit
import CoreData

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        switchRootToTabBar()
    }
    
    private func switchRootToTabBar() {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext

        let container = CoreDataContainer(context: context)
//        let trackerStore = TrackerStore(context: context)
//        let recordStore = TrackerRecordStore(context: context)
//        let categoryStore = TrackerCategoryStore(context: context)

        let tabBarController = MainTabBarController(container: container)

//        let tabBarController = MainTabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}

