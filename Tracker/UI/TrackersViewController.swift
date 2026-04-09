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
    private let datePicker = UIDatePicker()
    private let titleLabel = UILabel()
    private let emptyStageView = UIView()
    private let searchBar = UIView()
    private var addTrackerButtonItem = UIBarButtonItem()
    
    // MARK: - Private properties
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var changedTrackerId: UUID?
    private let trackersFactory = TrackersFactory.shared
    
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
        
        categories = trackersFactory.getTrackersCategory()
        completedTrackers = trackersFactory.getCompletedTrackers()
        
        if categories.isEmpty {
            setupEmptyStageView()
        } else {
            setupCollectionView()
        }
        
        helper?.delegate = self

        
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
    @objc private func addTrackerButtonTapped() {
        guard navigationController?.visibleViewController == self else { return }
        let createTrackerNavVC = UINavigationController(rootViewController: CreateTrackerViewController())
        self.present(createTrackerNavVC, animated: true)
    }
}

// MARK: - Private methods
private extension TrackersViewController {
    func setupUI() {
        setupNavButton()
        setupTitle()
        setupSearchBar()
        setupDatePicker()
    }
    
    func setupDatePicker() {
        let container = UIView()
        container.backgroundColor = .innerFields
        container.layer.cornerRadius = 10
        container.clipsToBounds = true

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            datePicker.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            datePicker.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    func setupNavButton() {
        setupAddTrackerButton()
        setupDatePicker()
    }
    
    func setupAddTrackerButton() {
        addTrackerButtonItem.style = .plain
        addTrackerButtonItem.image = UIImage(systemName: "plus")
        addTrackerButtonItem.target = self
        addTrackerButtonItem.action = #selector(addTrackerButtonTapped)
        navigationItem.leftBarButtonItem = addTrackerButtonItem
    }
    
    func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -105)
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
    
    func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        helper = SupplementaryCollection(categories: categories, completedTrackers: completedTrackers, using: params)
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
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        searchBar.backgroundColor = .innerFields
        searchBar.layer.cornerRadius = 10
        
        let searchIconIV = UIImageView()
        searchIconIV.frame.size = CGSize(width: 30, height: 30)
        searchIconIV.contentMode = .scaleAspectFit
        searchIconIV.image = UIImage(systemName: "magnifyingglass")
        searchIconIV.tintColor = .gray
        searchIconIV.image = searchIconIV.image?.withRenderingMode(.alwaysTemplate)
        searchIconIV.translatesAutoresizingMaskIntoConstraints = false
        searchBar.addSubview(searchIconIV)
        
        let textFieldInsideSearchBar = UITextField()
        textFieldInsideSearchBar.textColor = .gray
        textFieldInsideSearchBar.font = .systemFont(ofSize: 17, weight: .regular)
        textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [.foregroundColor: UIColor.gray]
        )
        textFieldInsideSearchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.addSubview(textFieldInsideSearchBar)
        
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 40),
            
            searchIconIV.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 8),
            searchIconIV.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 0),
            searchIconIV.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),

            textFieldInsideSearchBar.leadingAnchor.constraint(equalTo: searchIconIV.trailingAnchor, constant: 6),
            textFieldInsideSearchBar.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -7),
            textFieldInsideSearchBar.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 7),
            textFieldInsideSearchBar.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: -7)
        ])
    }
}

extension TrackersViewController: SupplementaryCollectionDelegate {
    func getSelectedData() -> Date {
        datePicker.date
    }
    
//    func getSelectedTrackerId() -> UUID {
//        UUID()
//    }
    
    func updateCell(with index: IndexPath) {
        fetchData()
        collectionView.reloadItems(at: [index])
    }
    
    private func fetchData() {
        categories = trackersFactory.getTrackersCategory()
        completedTrackers = trackersFactory.getCompletedTrackers()
    }
}
