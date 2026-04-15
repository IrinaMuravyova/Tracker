//
//  CategoriesVC.swift
//  Tracker
//
//  Created by Irina Muravyeva on 15.04.2026.
//

import UIKit

protocol CategoriesViewControllerProtocol: AnyObject {
    func categoryDidSelected(for category: String)
}

final class CategoriesViewController: UIViewController {
    // MARK: - UI
    private let saveButton = UIButton()
    private let tableView = UITableView()
    
    // MARK: - Private properties
    private var selectedCategory: String?
    private var trackersFactory: TrackersFactoryProtocol?
    
    // MARK: - Public Properties
    weak var delegate: CategoriesViewControllerProtocol?
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        trackersFactory = TrackersFactory.shared
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reusedIdentifier)
        
        saveButton.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Objc methods
    @objc private func saveButtonDidTap() {
        guard let title = selectedCategory,
              !title.isEmpty else { return }
        
        delegate?.categoryDidSelected(for: title)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI setting methods
private extension CategoriesViewController {
    func setupUI() {
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        
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
extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reusedIdentifier, for: indexPath) as? CategoryCell
        
        guard let cell else {
            fatalError("[CategoriesViewController] WeekCell has not been implemented")
            return UITableViewCell()
        }
        
        cell.configureDefault()
        
        if let selectedCategory = selectedCategory,
           cell.getCategoryTitle() == selectedCategory {
            cell.setSelected(true, animated: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else { return }
       
       selectedCategory = cell.getCategoryTitle()
       
       tableView.visibleCells.forEach { visibleCell in
           if let categoryCell = visibleCell as? CategoryCell {
               categoryCell.setSelected(false, animated: true)
           }
       }

       cell.setSelected(true, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
