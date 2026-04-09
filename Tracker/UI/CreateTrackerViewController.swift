//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 09.04.2026.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    //MARK: - UI
    private var habitButton: UIButton {
        let button = UIButton()
        button.frame.size = CGSize(width: 335, height: 60)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.titleLabel?.text = "Привычка"
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }
    
    private var irregularHabitButton: UIButton {
        let button = UIButton()
        button.frame.size = CGSize(width: 335, height: 60)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.titleLabel?.text = "Нерегулярное событие"
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private functions
    private func setupUI() {
        view.backgroundColor = .white
        
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(habitButton)
        
        irregularHabitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(irregularHabitButton)
        
        NSLayoutConstraint.activate([
            habitButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
           
            irregularHabitButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            irregularHabitButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            irregularHabitButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16)
            ])
    }
}
