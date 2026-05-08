//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 30.03.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - UI
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private let datePicker = UIDatePicker()
    private let titleLabel = UILabel()
    private let emptyStageView = UIView()
    private let searchBar = UIView()
    private let searchIconIV = UIImageView()
    private let textFieldInsideSearchBar = UITextField()
    private var addTrackerButtonItem = UIBarButtonItem()
    private let filterButton = UIButton()
    
    // MARK: - Private properties
    private var changedTrackerId: UUID?
    private var currentDate: Date = Date()
    private let container: CoreDataContainer
    private let viewModel: TrackerListViewModel

    init(
        container: CoreDataContainer,
        viewModel: TrackerListViewModel
    ) {
        self.container = container
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("[TrackersViewController] init(coder:) has not been implemented")
    }
    
    // MARK: - Public properties
    let params = GeometricParams(cellCount: 2,
                                 leftInset: 8,
                                 rightInset: 8,
                                 cellSpacing: 8)
    var helper: SupplementaryCollection?
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad( )
        setupUI()
        
        viewModel.onChange = { [weak self] in
            self?.updateUI()
        }
        
        updateUI()
    }
    
    // MARK: - Objc methods
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        viewModel.setDate(sender.date)
    }
    
    @objc private func addTrackerButtonTapped() {
        guard navigationController?.visibleViewController == self else { return }
        
        let trackerTypeVC = TrackerTypeSelectionViewController(container: container)
        trackerTypeVC.delegate = self
        let createTrackerNavVC = UINavigationController(rootViewController: trackerTypeVC)
        self.present(createTrackerNavVC, animated: true)
    }

    private func updateUI() {
        collectionView.reloadData()

        let isEmpty = viewModel.sections.isEmpty
        
        collectionView.isHidden = isEmpty
        emptyStageView.isHidden = !isEmpty
    }
}

// MARK: - SupplementaryCollectionDelegate
extension TrackersViewController: SupplementaryCollectionDelegate {
    func getSelectedDate() -> Date {
        currentDate
    }
    
    func updateCell(with index: IndexPath) {
        collectionView.reloadItems(at: [index])
    }
    
    func showNotAllowFutureDateAlert() {
        AlertHelper.showAlertWith(
            on: self,
            title: "Упс.. Что-то пошло не так",
            message: "Нельзя отметить привычку для будущей даты"
        )
    }
}

// MARK: - TrackerTypeSelectionViewControllerDelegate
extension TrackersViewController: TrackerTypeSelectionViewControllerDelegate {
    func reloadCollectionView() {
        updateUI()
    }
}

// MARK: - UI settings methods
private extension TrackersViewController {
    func setupUI() {
        view.backgroundColor = .white
        setupNavBar()
        setupTitle()
        setupSearchBar()
        setupFilterButton()
        setupCollectionView()
        setupEmptyStageView()
        setupConstraints()
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.backgroundColor = .white
        setupNavButton()
    }
    
    func setupNavButton() {
        setupAddTrackerButton()
        setupDatePicker()
    }
    
    func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
    }
    
    func setupSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        searchBar.backgroundColor = .innerFields
        searchBar.layer.cornerRadius = 10
        
        searchIconIV.frame.size = CGSize(width: 30, height: 30)
        searchIconIV.contentMode = .scaleAspectFit
        searchIconIV.image = UIImage(systemName: "magnifyingglass")
        searchIconIV.tintColor = .gray
        searchIconIV.image = searchIconIV.image?.withRenderingMode(.alwaysTemplate)
        searchIconIV.translatesAutoresizingMaskIntoConstraints = false
        searchBar.addSubview(searchIconIV)
        
        textFieldInsideSearchBar.textColor = .gray
        textFieldInsideSearchBar.font = .systemFont(ofSize: 17, weight: .regular)
        textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [.foregroundColor: UIColor.gray]
        )
        textFieldInsideSearchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.addSubview(textFieldInsideSearchBar)
    }
    
    func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = currentDate
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    func setupFilterButton() {
        filterButton.setTitle("Фильтры", for: .normal)
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        filterButton.backgroundColor = .onTintSwitch
        filterButton.layer.cornerRadius = 16
        
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)
    }
    
    func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        helper = SupplementaryCollection(
            using: params,
            container: container,
            viewModel: viewModel
        )
        helper?.delegate = self
        helper?.collectionView = collectionView
        
        collectionView.dataSource = helper
        collectionView.delegate = helper
        
        collectionView.register(
            TrackersCell.self,
            forCellWithReuseIdentifier: SupplementaryCollection.trackerCellIdentifier
        )
        
        collectionView.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SupplementaryView.reuseHeaderId)
    }
    
    func setupAddTrackerButton() {
        addTrackerButtonItem.style = .plain
        addTrackerButtonItem.tintColor = .blackDay
        addTrackerButtonItem.image = UIImage(systemName: "plus")
        addTrackerButtonItem.target = self
        addTrackerButtonItem.action = #selector(addTrackerButtonTapped)
        navigationItem.leftBarButtonItem = addTrackerButtonItem
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // searchBar
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 40),
            
            searchIconIV.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 8),
            searchIconIV.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchIconIV.heightAnchor.constraint(equalTo: searchBar.heightAnchor, multiplier: 0.6),
            searchIconIV.widthAnchor.constraint(equalTo: searchIconIV.heightAnchor),
            
            textFieldInsideSearchBar.leadingAnchor.constraint(equalTo: searchIconIV.trailingAnchor, constant: 6),
            textFieldInsideSearchBar.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -7),
            textFieldInsideSearchBar.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 7),
            textFieldInsideSearchBar.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: -7),
            
            // titleLabel
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -105),
            
            // filterButton
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            
            //collectionView
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: filterButton.topAnchor, constant: -16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func setupEmptyStageView() {
        let emptyStageImage = UIImageView()
        emptyStageImage.translatesAutoresizingMaskIntoConstraints = false
        emptyStageImage.image = UIImage(resource: ._1)
        
        let emptyStageLabel = UILabel()
        emptyStageLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStageLabel.text = "Что будем отслеживать?"
        emptyStageLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        emptyStageView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStageView.addSubview(emptyStageImage)
        emptyStageView.addSubview(emptyStageLabel)
        view.addSubview(emptyStageView)
        
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
}
