//
//  CreateCategoryVC.swift
//  Tracker
//
//  Created by Irina Muravyeva on 27.04.2026.
//

import UIKit

protocol CreateCategoryViewControllerProtocol: AnyObject {
    func categoryDidAdded(for category: String?)
}

final class CreateCategoryViewController: UIViewController {
    // MARK: - UI Properties
    private let tableView = UITableView()
    private let saveButton = UIButton()
    
    // MARK: - Private properties
    private var newCategory: String?
    private let container: CoreDataContainer
    
    // MARK: - Public properties
    weak var delegate: CreateCategoryViewControllerProtocol?
    
    // MARK: - Initializes
    init(container: CoreDataContainer) {
        self.container = container
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
    }
    
    // MARK: - Objective functions
    @objc private func saveButtonDidTap() {
        delegate?.categoryDidAdded(for: newCategory)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI setup
private extension CreateCategoryViewController {
    
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
        title = "Новая категория"
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
        saveButton.setTitle("Готово", for: .normal)
        
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
        
        cell.configureDefault(container: container)
        cell.delegate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - CategoryCellDelegate
extension CreateCategoryViewController: CategoryCellDelegate {
    func categoryDidUpdate(with title: String) {
        checkAndReturnSelectedCategory(title)
        newCategory = title
        updateOKButton(for: title)
    }
   
    private func updateOKButton(for title: String) {
        if title.isEmpty {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .grayButton
        } else {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .black
        }
    }
    
    private func checkAndReturnSelectedCategory(_ title: String) {
        guard !title.isEmpty else {
            AlertHelper.showAlertWith(
                on: self,
                title: "Упс.. Что-то пошло не так",
                message: "Нужно выбрать категорию"
            )
            return
        }
    }
}
