//
//  CreateCategoryVC.swift
//  Tracker
//
//  Created by Irina Muravyeva on 27.04.2026.
//

import UIKit

final class CreateCategoryViewController: UIViewController {
    // MARK: - UI Properties
    private let tableView = UITableView()
    private let saveButton = UIButton()
    
    // MARK: - Private properties
    private let viewModel: CreateCategoryViewModel
    
    // MARK: - Initializes
    init(viewModel: CreateCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("[CreateCategoryViewController] init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        viewModel.setupForMode()
    }
    
    // MARK: - Objective functions
    @objc private func saveButtonDidTap() {
        viewModel.saveCategory()
    }
}

// MARK: - UI setup
private extension CreateCategoryViewController {
    func bindViewModel() {
        viewModel.buttonStateDidChange = { [weak self] isEnabled in
            self?.saveButton.isEnabled = isEnabled
            self?.saveButton.backgroundColor =
            isEnabled ? .black : .grayButton
        }
        
        viewModel.categoryDidSave = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        viewModel.showError = { [weak self] message in
            guard let self else { return }
            
            AlertHelper.showAlertWith(
                on: self,
                title: NSLocalizedString(
                    "alert_title",
                    comment: "Text for alert title"
                ),
                message: message
            )
        }
        
        viewModel.updateNavigationTitle = { [weak self] title in
            self?.title = title
        }
    }
    
    func setupUI() {
        setupView()
        setupNavigationBar()
        setupCategoriesTableView()
        setupButton()
        setupConstraints()
    }
    
    func setupView() {
        view.backgroundColor = .white
    }
    
    func setupNavigationBar() {
        title = NSLocalizedString(
            "createcategory_navigationbar_title"
            , comment: "Text for create category navigation bar title"
        )
        navigationItem.hidesBackButton = true
    }
    
    func setupCategoriesTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reusedIdentifier)
        
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
    }
    
    func setupButton() {
        saveButton.layer.cornerRadius = 16
        saveButton.backgroundColor = .grayButton
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitle(
            NSLocalizedString(
                "createcategory_savebutton_title",
                comment: "Text for create category save button"
            ),
            for: .normal
        )
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        saveButton.isEnabled = false
        
        saveButton.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
    }
    
    func setupConstraints() {
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
extension CreateCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reusedIdentifier, for: indexPath) as? CategoryCell
        
        guard let cell else {
            fatalError("[CreateCategoryViewController] WeekCell has not been implemented")
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        if viewModel.categoryTitle.isEmpty {
            cell.configureDefault()
        } else {
            cell.configureEditable(with: viewModel.categoryTitle)
        }
        
        cell.configureAppearance(isFirst: true, isLast: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - CategoryCellDelegate
extension CreateCategoryViewController: CategoryCellDelegate {
    func categoryDidUpdate(with title: String) {
        viewModel.updateCategoryTitle(title)
    }
}
