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
        formatter.locale = Locale.current
        return formatter
    }()
    
    private let searchBar = UISearchBar()
    private let datePicker = UIDatePicker()
    private let titleLabel = UILabel()
    private let searchContainerView = UIView()
    private let emptyStageView = UIView()
    private let emptySearchResultView = UIView()
    private var addTrackerButtonItem = UIBarButtonItem()
    private let filterButton = UIButton()
    
    // MARK: - Private properties
    private var changedTrackerId: UUID?
    private var currentDate: Date = Date()
    private let container: CoreDataContainer
    private let trackerListViewModel: TrackerListViewModel
    private let analyticsService = AnalyticsService.shared
    
    // MARK: - Init
    init(
        container: CoreDataContainer,
        viewModel: TrackerListViewModel
    ) {
        self.container = container
        self.trackerListViewModel = viewModel
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
        super.viewDidLoad()
        setupUI()
        
        trackerListViewModel.onChange = { [weak self] in
            self?.updateUI()
        }
        trackerListViewModel.showAlert = { [weak self] title, message in
            guard let self = self else { return }
            
            AlertHelper.showAlertWith(
                on: self,
                title: title,
                message: message
            )
        }
        trackerListViewModel.onDateChangeRequested = { [weak self] newDate in
            self?.updateDatePicker(to: newDate)
        }
        
        updateUI()
    }
    
    // MARK: - Objc methods
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        trackerListViewModel.setDate(sender.date)
    }
    
    @objc private func addTrackerButtonTapped() {
        analyticsService.sendEvent(event: "click", screen: "Main", item: "add_track")
        
        guard navigationController?.visibleViewController == self else { return }
        
        let trackerTypeVC = TrackerTypeSelectionViewController(container: container)
        trackerTypeVC.delegate = self
        let createTrackerNavVC = UINavigationController(rootViewController: trackerTypeVC)
        self.present(createTrackerNavVC, animated: true)
    }
    
    @objc private func filterButtonTapped() {
        analyticsService.sendEvent(event: "click", screen: "Main", item: "filter")
        
        let currentFilter = trackerListViewModel.getCurrentFilter()
        let filtersVC = FiltersViewController(selectedFilter: currentFilter)
        filtersVC.delegate = self
        
        let navController = UINavigationController(rootViewController: filtersVC)
        navController.modalPresentationStyle = .pageSheet
        
        present(navController, animated: true)
    }
    
    // MARK: - Private methods
    private func updateUI() {
        collectionView.reloadData()
        
        let hasTrackersOnDate = trackerListViewModel.hasTrackersOnSelectedDate()
        let filterResultsEmpty = trackerListViewModel.sections.isEmpty
        let currentFilter = trackerListViewModel.getCurrentFilter()
        let isSearchActive = trackerListViewModel.isSearchActive
        
        if isSearchActive && filterResultsEmpty {
            collectionView.isHidden = true
            emptyStageView.isHidden = true
            emptySearchResultView.isHidden = false
            filterButton.isHidden = true
        }
        else if !hasTrackersOnDate {
            collectionView.isHidden = true
            emptyStageView.isHidden = false
            emptySearchResultView.isHidden = true
            filterButton.isHidden = true
        }
        else if filterResultsEmpty && currentFilter != .allTrackers && !isSearchActive {
            collectionView.isHidden = true
            emptyStageView.isHidden = true
            emptySearchResultView.isHidden = false
            filterButton.isHidden = false
        }
        else {
            collectionView.isHidden = false
            emptyStageView.isHidden = true
            emptySearchResultView.isHidden = true
            filterButton.isHidden = false
        }
        
        view.bringSubviewToFront(filterButton)
        
        if trackerListViewModel.getCurrentFilter() != .allTrackers,
           trackerListViewModel.getCurrentFilter() != .todayTrackers {
            filterButton.backgroundColor = .red
        } else {
            filterButton.backgroundColor = .onTintSwitch
        }
    }
    
    private func updateDatePicker(to date: Date) {
        datePicker.date = date
        currentDate = date
        
        trackerListViewModel.setDate(date)
    }
    
    private func clearSearchIfNeeded() {
        if let searchText = searchBar.text, !searchText.isEmpty {
            searchBar.text = ""
            trackerListViewModel.updateSearchText("")
        }
    }
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        trackerListViewModel.updateSearchText("")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        trackerListViewModel.updateSearchText(searchText)
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
    
    func openEditTracker(_ viewModel: EditTrackerViewModel, completedCount: Int) {
        let editVC = EditTrackerViewController(viewModel: viewModel, completedCount: completedCount)
        
        viewModel.onTrackerSaved = { [weak self] in
            self?.trackerListViewModel.updateSections()
        }
        
        let navController = UINavigationController(rootViewController: editVC)
        navController.modalPresentationStyle = .pageSheet
        
        navigationController?.present(navController, animated: true)
    }
    
    func presentDeleteTrackerAlert(for indexPath: IndexPath) {
        let alert = UIAlertController(
            title: NSLocalizedString(
                "delete_tracker_alert_title",
                comment: "Delete tracker confirmation title"
            ),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let delete = UIAlertAction(
            title: NSLocalizedString(
                "delete",
                comment: "Delete action"
            ),
            style: .destructive
        ) { [weak self] _ in
            self?.analyticsService.sendEvent(event: "click", screen: "Main", item: "delete")
            
            self?.trackerListViewModel.requestDeleteTracker(at: indexPath)
        }
        
        let cancel = UIAlertAction(
            title: NSLocalizedString(
                "cancel",
                comment: "Cancel action"
            ),
            style: .cancel
        )
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.sendEvent(event: "open", screen: "Main", item: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.sendEvent(event: "close", screen: "Main", item: nil)
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
        view.backgroundColor = .trackersVCBackground
        setupNavBar()
        setupTitle()
        setupSearchController()
        setupCollectionView()
        setupFilterButton()
        setupEmptyStageView()
        setupEmptySearchResultView()
        setupConstraints()
    }
    
    func setupNavBar() {
        navigationItem.title = ""
        navigationController?.navigationBar.backgroundColor = .trackersVCBackground
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        setupNavButton()
    }
    
    func setupNavButton() {
        setupAddTrackerButton()
        setupDatePicker()
    }
    
    func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString(
            "trackervc_title",
            comment: "Title for main trackers list"
        )
        titleLabel.textColor = .textColor
        
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
    }
    
    func setupSearchController() {
        
        searchBar.placeholder = NSLocalizedString(
            "search",
            comment: "Search placeholder"
        )
        
        searchBar.delegate = self
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("search", comment: ""),
            attributes: [
                .foregroundColor: UIColor.searchTextPlacholder
            ]
        )
        
        searchBar.searchTextField.leftView?.tintColor = .searchTextPlacholder
        searchBar.backgroundImage = UIImage()
        
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchContainerView)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchContainerView.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
            
            searchContainerView.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = currentDate
        datePicker.locale = Locale.current
        
        datePicker.overrideUserInterfaceStyle = .light
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    func setupFilterButton() {
        filterButton.setTitle(
            NSLocalizedString(
                "filters",
                comment: "Title for filter button"
            ),
            for: .normal
        )
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        filterButton.backgroundColor = .onTintSwitch
        filterButton.layer.cornerRadius = 16
        
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)
        
        filterButton.overrideUserInterfaceStyle = .light
        
        filterButton.layer.zPosition = 1
        view.bringSubviewToFront(filterButton)
        
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    func setupCollectionView() {
        collectionView.backgroundColor = .trackersVCBackground
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        helper = SupplementaryCollection(
            using: params,
            container: container,
            viewModel: trackerListViewModel
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
        addTrackerButtonItem.tintColor = .textColor
        addTrackerButtonItem.image = UIImage(systemName: "plus")
        addTrackerButtonItem.target = self
        addTrackerButtonItem.action = #selector(addTrackerButtonTapped)
        navigationItem.leftBarButtonItem = addTrackerButtonItem
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -105),
            
            searchContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
        ])
    }
    
    func setupEmptyStageView() {
        let emptyStageImage = UIImageView()
        emptyStageImage.translatesAutoresizingMaskIntoConstraints = false
        emptyStageImage.image = UIImage(resource: ._1)
        
        let emptyStageLabel = UILabel()
        emptyStageLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStageLabel.text = NSLocalizedString(
            "empty_stage_label_text",
            comment: "Text for label without any trackers"
        )
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
    
    func setupEmptySearchResultView() {
        let emptySearchImage = UIImageView()
        emptySearchImage.translatesAutoresizingMaskIntoConstraints = false
        emptySearchImage.image = UIImage(resource: .emptySearch)
        emptySearchImage.tintColor = .gray
        emptySearchImage.contentMode = .scaleAspectFit
        
        let emptySearchLabel = UILabel()
        emptySearchLabel.translatesAutoresizingMaskIntoConstraints = false
        emptySearchLabel.text = NSLocalizedString(
            "empty_search_result_text",
            comment: "Text for label when no filter results"
        )
        emptySearchLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptySearchLabel.textColor = .gray
        emptySearchLabel.textAlignment = .center
        
        emptySearchResultView.translatesAutoresizingMaskIntoConstraints = false
        emptySearchResultView.isHidden = true
        
        emptySearchResultView.addSubview(emptySearchImage)
        emptySearchResultView.addSubview(emptySearchLabel)
        view.addSubview(emptySearchResultView)
        
        NSLayoutConstraint.activate([
            emptySearchImage.centerXAnchor.constraint(equalTo: emptySearchResultView.centerXAnchor),
            emptySearchImage.centerYAnchor.constraint(equalTo: emptySearchResultView.centerYAnchor),
            emptySearchImage.widthAnchor.constraint(equalToConstant: 80),
            emptySearchImage.heightAnchor.constraint(equalToConstant: 80),
            
            emptySearchLabel.topAnchor.constraint(equalTo: emptySearchImage.bottomAnchor, constant: 8),
            emptySearchLabel.centerXAnchor.constraint(equalTo: emptySearchResultView.centerXAnchor),
            emptySearchLabel.leadingAnchor.constraint(greaterThanOrEqualTo: emptySearchResultView.leadingAnchor, constant: 16),
            emptySearchLabel.trailingAnchor.constraint(lessThanOrEqualTo: emptySearchResultView.trailingAnchor, constant: -16),
            
            emptySearchResultView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptySearchResultView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(_ filter: FilterOption) {
        trackerListViewModel.setFilter(filter)
    }
}
