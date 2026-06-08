//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 09.04.2026.
//

import UIKit

protocol TrackerTypeSelectionViewControllerDelegate: AnyObject {
    func reloadCollectionView()
}

final class TrackerTypeSelectionViewController: UIViewController {
    //MARK: - UI
    private let habitButton: UIButton = {
        let button = UIButton()
        button.frame.size = CGSize(width: 335, height: 60)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.setTitle(
            NSLocalizedString(
                "habitbutton_title",
                comment: "Text for the button that allows to select a habit"),
            for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton()
        button.frame.size = CGSize(width: 335, height: 60)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.setTitle(
            NSLocalizedString(
                "irregular_event_button_title",
                comment: "Text for the button that allows to select an irregular event"),
            for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    // MARK: - Private properties
    private let container: CoreDataContainer
    
    // MARK: - Public properties
    weak var delegate: TrackerTypeSelectionViewControllerDelegate?
    
    init(container: CoreDataContainer) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("[TrackerTypeSelectionViewController] init(coder:) has not been implemented")
    }
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        habitButton.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Objc methods
    @objc private func buttonDidTap(_ sender: UIButton) {
        let type = sender == habitButton ? TrackerType.habit : TrackerType.irregular

        let viewModel = TrackerViewModel(trackerType: type, container: container)
        let createViewModel = CreateTrackerViewModel(viewModel: viewModel)
        let trackerDetailsVC = TrackerDetailsViewController(viewModel: createViewModel)

        trackerDetailsVC.delegate = self
        navigationController?.pushViewController(trackerDetailsVC, animated: true)
    }
    
    // MARK: - Private functions
    private func setupUI() {
        view.backgroundColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = nil
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.blackDay
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.title = NSLocalizedString(
            "create_event_navigation_item_title",
            comment: "Text for the title of the navigation item in the Tracker Type Selection View Controller"
        )
        
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(habitButton)
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(irregularEventButton)
        
        NSLayoutConstraint.activate([
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.widthAnchor.constraint(equalToConstant: 335),
            habitButton.heightAnchor.constraint(equalToConstant: 60),

            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularEventButton.widthAnchor.constraint(equalToConstant: 335),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension TrackerTypeSelectionViewController: TrackerDetailsViewControllerDelegate {
    func trackersDidChanged() {
        delegate?.reloadCollectionView()
    }
}
