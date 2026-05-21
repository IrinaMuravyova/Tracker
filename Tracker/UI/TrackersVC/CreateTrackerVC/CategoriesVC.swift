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
        viewModel.fetchCategories()
    }
    
    // MARK: - Objc methods
    @objc private func addButtonDidTap() {
        let createCategoryVC = CreateCategoryViewController(
            viewModel: viewModel.makeCreateCategoryViewModel()
        )

        createCategoryVC.onCategoryCreated = { [weak self] in
            self?.viewModel.fetchCategories()
        }

        navigationController?.pushViewController(createCategoryVC, animated: true)
    }
}

// MARK: - UI setting methods
private extension CategoriesViewController {
    func bindViewModel() {
        viewModel.categoriesDidChange = { [weak self] in
            guard let self else { return }
        
            self.updateUI()
            self.tableView.reloadData()
        }

        viewModel.selectedCategoryDidChange = { [weak self] category in
            guard let self else { return }
            self.delegate?.categoryDidSelected(for: category)
        }
    }
    
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
        saveButton.setTitle("Добавить категорию", for: .normal)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        saveButton.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
    }
    
    func setupEmptyStageView() {
        emptyStageImage.translatesAutoresizingMaskIntoConstraints = false
        emptyStageImage.image = UIImage(resource: ._1)
        
        emptyStageLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStageLabel.text = "Привычки и события можно объединить по смыслу"
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
        return viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reusedIdentifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
  
        let category = viewModel.category(at: indexPath.row)
        cell.configure(with: category)
        
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == viewModel.numberOfCategories - 1
        cell.configureAppearance(isFirst: isFirst, isLast: isLast)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
