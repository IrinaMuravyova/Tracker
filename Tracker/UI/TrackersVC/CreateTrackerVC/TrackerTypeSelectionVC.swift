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
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton()
        button.frame.size = CGSize(width: 335, height: 60)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    // MARK: - Public properties
    weak var delegate: TrackerTypeSelectionViewControllerDelegate?
    
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
        let trackerDetailsVC = TrackerDetailsViewController(trackerType: type)
        trackerDetailsVC.delegate = self
        navigationController?.pushViewController(trackerDetailsVC, animated: true)
    }
    
    // MARK: - Private functions
    private func setupUI() {
        view.backgroundColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.blackDay
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.title = "Создание трекера"
        
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
