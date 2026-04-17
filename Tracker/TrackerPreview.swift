//
//  TrackerDetailsPreview.swift
//  Tracker
//
//  Created by Irina Muravyeva on 10.04.2026.
//

import SwiftUI

struct TrackerDetailsPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return TrackerDetailsViewController(trackerType: .habit)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

#Preview {
    TrackerDetailsPreview()
}
