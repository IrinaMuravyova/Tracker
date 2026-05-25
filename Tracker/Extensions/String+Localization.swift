//
//  String+Localization.swift
//  Tracker
//
//  Created by Irina Muravyeva on 25.05.2026.
//

import Foundation

extension String {
    static func localizedDaysString(for count: Int) -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString("dayString", comment: "Number of marked days for habit"),
            count
        )
    }
}
