//
//  UIColor + DarkMode.swift
//  Tracker
//
//  Created by Irina Muravyeva on 28.05.2026.
//

import UIKit

extension UIColor {
    static var trackersVCBackground: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? .whiteNight
            : .whiteDay
        }
    }
    
    static var textColor: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? .blackNight
            : .blackDay
        }
    }
    static var searchTextPlacholder: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? .searchTextNight
            : .gray
        }
    }
}
