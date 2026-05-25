//
//  EditTrackerViewController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 23.05.2026.
//

import UIKit

final class EditTrackerViewController: TrackerDetailsViewController {
    // MARK: - UI
    private let completedCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .blackDay
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    let editViewModel: EditTrackerViewModel
    let completedCount: Int
  
    // MARK: - Bindings
    var onTrackerSaved: (() -> Void)?
    
    // MARK: - Initializer
    init(viewModel: EditTrackerViewModel, completedCount: Int) {
        self.editViewModel = viewModel
        self.completedCount = completedCount
        super.init(viewModel: viewModel)
    }
   
    required init?(coder: NSCoder) {
        fatalError("[EditTrackerViewController] init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        layoutDelegate = self
        super.viewDidLoad()
        
        title = NSLocalizedString("edit_screen_title", comment: "Title for the edit tracker screen")
        
        updateCompletedCount()
        updateUIWithViewModel()
    }
    
    // MARK: - Private Methods
    private func updateCompletedCount() {
        completedCountLabel.text = "\(String.localizedDaysString(for: completedCount))"
    }
}

extension EditTrackerViewController: TrackerDetailsLayoutDelegate {
    func additionalViewsToInsert() -> [(view: UIView, spacing: CGFloat)] {
        return [(completedCountLabel, 40)]
    }
}

extension EditTrackerViewController {
    func updateCompletedCount(with count: Int) {
        let text = String.localizedStringWithFormat(
            NSLocalizedString("completed_count_format", comment: "Format for completed count"),
            count
        )
        completedCountLabel.text = text
    }
}
