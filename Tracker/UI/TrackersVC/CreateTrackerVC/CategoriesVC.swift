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
    private let emptyStageView = UIView()
    private let emptyStageImage = UIImageView()
    private let emptyStageLabel = UILabel()
    
    // MARK: - Private properties
    private let viewModel: CategoriesViewModel
    private var contextMenuIndexPath: IndexPath?

    
    // MARK: - Public Properties
    weak var delegate: CategoriesViewControllerProtocol?

    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("[CategoriesViewController] init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        
        updateSelectedCategory()
    }
    
    // MARK: - Objc methods
    @objc private func addButtonDidTap() {
        let createCategoryVC = CreateCategoryViewController(
            viewModel: viewModel.makeCreateCategoryViewModel()
        )
        
        navigationController?.pushViewController(createCategoryVC, animated: true)
    }
    
    private func bindViewModel() {
        viewModel.categoriesDidChange = { [weak self] in
            guard let self else { return }
        
            self.updateUI()
            self.tableView.reloadData()
            self.updateSelectedCategory()
        }

        viewModel.selectedCategoryDidChange = { [weak self] category in
            guard let self else { return }
            self.delegate?.categoryDidSelected(for: category)
        }
    }
    
    // MARK: - Public methods
    func updateSelectedCategory() {
        guard let selectedCategory = viewModel.selectedCategory else { return }

        guard let row = (0..<viewModel.numberOfCategories)
            .first(where: {
                viewModel.category(at: $0).title == selectedCategory
            })
        else {
            return
        }

        let indexPath = IndexPath(row: row, section: 0)

        tableView.selectRow(
            at: indexPath,
            animated: false,
            scrollPosition: .none
        )
    }
}

// MARK: - UI setting methods
private extension CategoriesViewController {
    func updateUI() {
        emptyStageView.isHidden = !viewModel.isEmpty
        tableView.isHidden = viewModel.isEmpty
    }
    
    func setupUI() {
        setupView()
        setupNavigationBar()
        setupSaveButton()
        setupSaveButtonConstraints()
        
        setupEmptyStageView()
        setupEmptyStageConstraints()
        
        setupCategoriesTableView()
        setupConstraints()

        updateUI()
    }
    
    func setupView() {
        view.backgroundColor = .white
    }
    
    func setupNavigationBar() {
        navigationItem.hidesBackButton = true
    }
    
    func setupSaveButton() {
        saveButton.layer.cornerRadius = 16
        saveButton.backgroundColor = .blackDay
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        saveButton.setTitleColor(.white, for: .normal)
        
        let saveButtonTitle = NSLocalizedString(
            "savebutton_title",
            comment: "Text on the button that saves the changes"
        )
        saveButton.setTitle(saveButtonTitle, for: .normal)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        saveButton.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
    }
    
    func setupEmptyStageView() {
        emptyStageImage.translatesAutoresizingMaskIntoConstraints = false
        emptyStageImage.image = UIImage(resource: ._1)
        
        emptyStageLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStageLabel.text = NSLocalizedString(
            "emptystagelabel_text",
            comment: "Text in the empty stage view"
        )
        emptyStageLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyStageLabel.numberOfLines = 0
        emptyStageLabel.textAlignment = .center
        
        emptyStageView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStageView.addSubview(emptyStageImage)
        emptyStageView.addSubview(emptyStageLabel)
        view.addSubview(emptyStageView)
    }
    
    func setupCategoriesTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reusedIdentifier)
        
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
    }
    
    func setupEmptyStageConstraints() {
        NSLayoutConstraint.activate([
            emptyStageImage.centerXAnchor.constraint(equalTo: emptyStageView.centerXAnchor),
            emptyStageImage.centerYAnchor.constraint(equalTo: emptyStageView.centerYAnchor),
            emptyStageImage.widthAnchor.constraint(equalToConstant: 80),
            emptyStageImage.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStageLabel.topAnchor.constraint(equalTo: emptyStageImage.bottomAnchor, constant: 8),
            emptyStageLabel.centerXAnchor.constraint(equalTo: emptyStageView.centerXAnchor),
            
            emptyStageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func setupSaveButtonConstraints() {
        NSLayoutConstraint.activate([
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
        viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reusedIdentifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
  
        let category = viewModel.category(at: indexPath.row)
        
        if let title = category.title {
            cell.configure(with: title)
        } else {
            print("[CategoriesVC] category.title is nil")
            cell.configure(with: "")
        }
    
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == viewModel.numberOfCategories - 1
        cell.configureAppearance(isFirst: isFirst, isLast: isLast)
        
        let isSelected = category.title == viewModel.selectedCategory
        if isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.setSelected(true, animated: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - Context Menu Actions
extension CategoriesViewController {
    private func showDeleteConfirmation(for indexPath: IndexPath) {
        let alertController = UIAlertController(
            title: NSLocalizedString(
                "alert_message_for_delete_category", comment: ""
            ),
            message: "",
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString(
                "delete", comment: ""
            ),
            style: .destructive
        ) { [weak self] _ in
            self?.viewModel.deleteCategory(at: indexPath.row)
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString(
                "cancel", comment: ""
            ),
            style: .cancel
        )
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}

// MARK: - Context Menu Configuration
extension CategoriesViewController {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        contextMenuIndexPath = indexPath
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in
            guard let self = self else { return UIMenu(title: "") }
        
            let editAction = UIAction(
                title: NSLocalizedString(
                    "edit",
                    comment: "Title for edit action"
                )
            ) { [weak self] _ in
                guard let self else { return }
                let editViewModel = self.viewModel.makeEditCategoryViewModel(at: indexPath.row)
                
                guard let editViewModel else { return }
                let editCategoryVC = CreateCategoryViewController(viewModel: editViewModel)
                navigationController?.pushViewController(editCategoryVC, animated: true)
            }
            
            let deleteAction = UIAction(
                title: NSLocalizedString(
                    "delete",
                    comment: "Title for delete action"
                ),
                attributes: .destructive
            ) { [weak self] _ in
                self?.showDeleteConfirmation(for: indexPath)
            }
            
            return UIMenu(
                title:"",
                children: [editAction, deleteAction]
            )
        }
    }
}
