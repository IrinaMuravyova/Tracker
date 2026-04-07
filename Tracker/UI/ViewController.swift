//
//  ViewController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 26.03.2026.
//

import UIKit

class ViewController: UIViewController {
    var logoImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchToTabBarController()
    }
}

private extension ViewController {
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = MainTabBarController()
        window.rootViewController = tabBarController
    }
}
