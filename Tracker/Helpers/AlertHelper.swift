//
//  AlertHelper.swift
//  Tracker
//
//  Created by Irina Muravyeva on 27.04.2026.
//

import UIKit

struct AlertHelper {
    static func showAlertWith(
        on viewController: UIViewController,
        title: String,
        message: String,
        buttonTitle: String = NSLocalizedString(
            "alert_okbutton_title",
            comment: "Text displayed button title for OK button at an alert"
        ),
        completion: (() -> Void)? = nil) {
            
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonTitle, style: .default) { _ in
            completion?()
        }
            
        alert.addAction(okAction)
        viewController.present(alert, animated: true)
    }
}
