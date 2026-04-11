//
//  ScheduleSettingsVC.swift
//  Tracker
//
//  Created by Irina Muravyeva on 11.04.2026.
//

import UIKit

protocol ScheduleSettingsVCProtocol: AnyObject {
    func scheduleDidSetup(for days: Set<Weekday>)
}

final class ScheduleSettingsVC: UIViewController {
    // MARK: - UI
    private let saveButton = UIButton()
    private let tableView = UITableView()
    
    // MARK: - Private properties
    private var selectedDays: Set<Weekday> = []
    weak var delegate: ScheduleSettingsVCProtocol?
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(WeekdayCell.self, forCellReuseIdentifier: WeekdayCell.reusedIdentifier)
        
        saveButton.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Objc methods
    @objc private func saveButtonDidTap() {
        delegate?.scheduleDidSetup(for: selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI setting methods
private extension ScheduleSettingsVC {
    func setupUI() {
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        saveButton.layer.cornerRadius = 16
        saveButton.backgroundColor = .blackDay
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitle("Готово", for: .normal)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.widthAnchor.constraint(equalToConstant: 335),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ScheduleSettingsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Weekday.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeekdayCell.reusedIdentifier, for: indexPath) as? WeekdayCell
        
        let day = Weekday.allCases[indexPath.row]

        guard let cell else {
            fatalError("[ScheduleSettingsVC] WeekCell has not been implemented")
            return UITableViewCell()
        }
        cell.configure(with: indexPath.row, isOn: selectedDays.contains(day))
        
        cell.onToggle = { [weak self] day, isOn in
            guard let self else { return }

            if isOn {
                self.selectedDays.insert(day)
            } else {
                self.selectedDays.remove(day)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let day = Weekday.allCases[indexPath.row]

        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
