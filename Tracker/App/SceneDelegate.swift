//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Irina Muravyeva on 26.03.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        switchRootToTabBar()
    }
    
    private func switchRootToTabBar() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("[SceneDelegate] Unable to get AppDelegate")
            return
        }
        
        let container = CoreDataContainer()
        
        let tabBarController = MainTabBarController(
            container: container,
            viewModel: TrackerListUIModel(
                container: container
            )
        )

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}

