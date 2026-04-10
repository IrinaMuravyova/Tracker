//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 09.04.2026.
//

import UIKit

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
    
    private let irregularHabitButton: UIButton = {
        let button = UIButton()
        button.frame.size = CGSize(width: 335, height: 60)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        habitButton.addTarget(self, action: #selector(habitButtonDidTap), for: .touchUpInside)
    }
    
    @objc private func habitButtonDidTap() {
        let trackerDetailsVC = TrackerDetailsViewController(trackerType: .habit)
        trackerDetailsVC.title = "Новая привычка"
        navigationController?.setViewControllers([trackerDetailsVC], animated: true)
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
        irregularHabitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(irregularHabitButton)
        
        NSLayoutConstraint.activate([
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.widthAnchor.constraint(equalToConstant: 335),
            habitButton.heightAnchor.constraint(equalToConstant: 60),

            irregularHabitButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularHabitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularHabitButton.widthAnchor.constraint(equalToConstant: 335),
            irregularHabitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
