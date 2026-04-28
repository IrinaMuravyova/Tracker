//
//  TrackerDetailsViewController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 09.04.2026.
//

import UIKit

private struct TrackerDraft {
    var title: String
    var category: String
    var schedule: Set<Weekday>
    var selectedEmoji: String?
    var selectedColor: UIColor?
}

protocol TrackerDetailsViewControllerDelegate: AnyObject {
    func trackersDidChanged()
}

final class TrackerDetailsViewController: UIViewController {
    // MARK: - UI
    private let titleTF = UITextField()
    private let titleFooter = UILabel()
    private var titleStack = UIStackView()
    private var detailsStackView = UIStackView()
    private var categoryView: BaseDetailsItem?
    private var scheduleView: BaseDetailsItem?
    private var buttonStackView = UIStackView()
    private let cancelButton = UIButton()
    private let saveButton = UIButton()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size.height = 1
        return view
    }()
    
    private let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let colorCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let emojiLabel = UILabel()
    private let colorLabel = UILabel()
    
    // MARK: - Private properties
    private let trackerType: TrackerType
    private var trackerDraft = TrackerDraft(
        title: "",
        category: "",
        schedule: []
    )
    private let scheduleSettingsVC = ScheduleSettingsVC()
    private let trackerFactory: TrackersFactoryProtocol? = TrackersFactory.shared
    weak var delegate: TrackerDetailsViewControllerDelegate?
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    
    private let container: CoreDataContainer
    
    // MARK: - Initializes
    init(trackerType: TrackerType, container: CoreDataContainer) {
        self.trackerType = trackerType
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("[TrackerDetailsViewController] init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        let isHabit = trackerType == .habit
        title = isHabit
            ? "Новая привычка"
            : "Новое нерегулярное событие"
        
        saveButton.isEnabled = false
        setupUI()
        scheduleView?.isHidden = trackerType != .habit
        
        if !isHabit {
            scheduleView?.isHidden = true
            separator.isHidden = true
        }
        
        scheduleSettingsVC.delegate = self
        let categoriesSettingsVC = CategoriesViewController(container: container)
        categoriesSettingsVC.delegate = self
        
        categoryView?.onTap = { [weak self] in
            guard let self else { return }
            
            categoriesSettingsVC.title = self.categoryView?.getTitle()
            self.navigationController?.pushViewController(categoriesSettingsVC, animated: true)
        }
        
        scheduleView?.onTap = { [weak self] in
            guard let self else { return }
            
            self.scheduleSettingsVC.title = self.scheduleView?.getTitle()
            self.navigationController?.pushViewController(self.scheduleSettingsVC, animated: true)
        }
        
        emojiCollection.delegate = self
        emojiCollection.dataSource = self
        colorCollection.delegate = self
        colorCollection.dataSource = self
        
        emojiCollection.register(EmojisCollectionViewCell.self, forCellWithReuseIdentifier: EmojisCollectionViewCell.reusedIdentifier)
        colorCollection.register(ColorsCollectionViewCell.self, forCellWithReuseIdentifier: ColorsCollectionViewCell.reusedIdentifier)

        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
        
        titleTF.addTarget(self, action: #selector(titleDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - Objc methods
    @objc private func cancelButtonDidTap() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonDidTap() {
        guard let trackerFactory else { return }
        // сохранить трекер
        // добавить трекер в массив в категории
        // закрыть окно
        // обновить UШ
        //TODO: сохранить в базу в фоне
        let newTracker = Tracker(
            id: UUID(),
            name: trackerDraft.title,
            color: TrackerColor.colorselection1,
            emoji: "",
            schedule: TrackerSchedule.daysOfWeek(trackerDraft.schedule),
            type: trackerType)
        
        do {
            try container.trackerStore.add(newTracker, to: trackerDraft.category)
        } catch {
            print("Failed to add newTracker: \(error)")
        }
        
        delegate?.trackersDidChanged()
        dismiss(animated: true)
    }
    
    @objc private func titleDidChange(_ textField: UITextField) {
        trackerDraft.title = textField.text ?? ""
        updateSaveButtonState()
    }
}

// MARK: - Private methods
private extension TrackerDetailsViewController {
    private func updateSaveButtonState() {
        let isValid: Bool = {
            if trackerType == .habit {
                return !trackerDraft.title.isEmpty &&
                       !trackerDraft.category.isEmpty &&
                       !trackerDraft.schedule.isEmpty
            } else {
                return !trackerDraft.title.isEmpty &&
                       !trackerDraft.category.isEmpty
            }
        }()
        
        saveButton.isEnabled = isValid
        saveButtonSetupColors()
    }
}

// MARK: - UI settings methods
private extension TrackerDetailsViewController {
    func setupUI() {
        view.backgroundColor = .white
        setupScrollView()
        setupTitleStack()
        setupDetailsView()
        setupButtons()
        setupCollections()
        setupConstraints()
    }
    
    func setupScrollView() {
        scrollView.alwaysBounceVertical = true
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.panGestureRecognizer.cancelsTouchesInView = false
    }

    func setupTitleStack() {
        setupTitleTF()
        setupTitleFooter()
        
        titleStack = UIStackView(arrangedSubviews: [titleTF, titleFooter])
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleStack)
        
        titleStack.axis = .vertical
        titleStack.spacing = 8
    }
    
    func setupTitleTF() {
        titleTF.translatesAutoresizingMaskIntoConstraints = false
        
        titleTF.placeholder = "Введите название трекера"
        titleTF.layer.cornerRadius = 16
        titleTF.backgroundColor = .backgroundDay
        view.layer.cornerRadius = 16
        
        titleTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        titleTF.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))

        titleTF.leftViewMode = .always
        titleTF.rightViewMode = .always
        
        titleTF.keyboardType = .default
        titleTF.returnKeyType = .go
        
        titleTF.delegate = self
        titleTF.enablesReturnKeyAutomatically = true
        titleTF.autocapitalizationType = .sentences
    }
    
    func setupTitleFooter() {
        titleFooter.font = .systemFont(ofSize: 17, weight: .regular)
        titleFooter.textColor = .redFigma
        titleFooter.text = "Ограничение 38 символов"
        titleFooter.textAlignment = .center
        titleFooter.translatesAutoresizingMaskIntoConstraints = false
        titleFooter.isHidden = true
    }
    
    func setupDetailsView() {
        categoryView = BaseDetailsItem(
            withTitle: "Категория",
            subTitle: ""
        )
        
        scheduleView = BaseDetailsItem(
            withTitle: "Расписание",
            subTitle: ""
        )
        
        guard
            let categoryView = categoryView as? UIView,
            let scheduleView = scheduleView as? UIView
        else {
            fatalError("[TrackerDetailsViewController] categoryView or scheduleView is not UIView")
            return
        }
        
        detailsStackView = UIStackView(
            arrangedSubviews: [categoryView, separator,  scheduleView]
        )
        detailsStackView.axis = .vertical
        detailsStackView.alignment = .fill
        detailsStackView.distribution = .fillProportionally
        detailsStackView.backgroundColor = .backgroundDay
        detailsStackView.layer.cornerRadius = 16

        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(detailsStackView)
    }
    
    func setupCollections() {
        setupEmojiCollection()
        setupColorCollection()
        setupEmojiLabel()
        setupColorLabel()
    }
    
    func setupEmojiCollection() {
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiCollection)
        
        emojiCollection.contentInset = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
        emojiCollection.isScrollEnabled = false
    }
    
    func setupColorCollection() {
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorCollection)
        
        colorCollection.contentInset = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
        colorCollection.isScrollEnabled = false
    }
    
    func setupEmojiLabel() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        emojiLabel.font = .systemFont(ofSize: 19, weight: .bold)
        emojiLabel.textColor = .blackDay
        emojiLabel.text = "Emoji"
    }
    
    func setupColorLabel() {
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorLabel)
        colorLabel.font = .systemFont(ofSize: 19, weight: .bold)
        colorLabel.textColor = .blackDay
        colorLabel.text = "Цвет"
    }
    
    func setupButtons() {
        buttonStackView = UIStackView(
            arrangedSubviews: [cancelButton, saveButton]
        )
        
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 8
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.redFigma, for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.redFigma.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.backgroundColor = .white
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Создать", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        saveButton.setTitleColor(.white, for: .normal)
        saveButtonSetupColors()
        saveButton.layer.cornerRadius = 16
    }
    
    func saveButtonSetupColors() {
        saveButton.backgroundColor = saveButton.isEnabled ? .blackDay : .gray
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // scrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),

            // contentView
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // titleTextField
            titleTF.heightAnchor.constraint(equalToConstant: 75),
            
            // titleStack
            titleStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleStack.topAnchor.constraint(equalTo:  contentView.topAnchor, constant: 24),
            
            // separator
            separator.leadingAnchor.constraint(equalTo: detailsStackView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: detailsStackView.trailingAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            // detailsStackView
            detailsStackView.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 24),
            detailsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // emojiCollectionView
            emojiLabel.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiLabel.heightAnchor.constraint(equalToConstant: 18),
            
            emojiCollection.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            emojiCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollection.heightAnchor.constraint(equalToConstant: 204),
            

            colorLabel.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorLabel.heightAnchor.constraint(equalToConstant: 18),
            
            colorCollection.topAnchor.constraint(equalTo: colorLabel.bottomAnchor),
            colorCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            colorCollection.heightAnchor.constraint(equalToConstant: 204),
            
            // buttons
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 161),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.widthAnchor.constraint(equalToConstant: 161),
            
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension TrackerDetailsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        titleFooter.isHidden = updatedText.count != 39
        
        return updatedText.count <= 38
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else {
            return false
        }
        trackerDraft.title = text
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - ScheduleSettingsVCProtocol
extension TrackerDetailsViewController: ScheduleSettingsVCProtocol {
    func scheduleDidSetup(for days: Set<Weekday>) {
        trackerDraft.schedule = days
        updateScheduleView()
        updateSaveButtonState()
    }
    
    private func updateScheduleView() {
        let daysString = trackerDraft.schedule.count == Weekday.allCases.count
        ? "Каждый день"
        : trackerDraft.schedule
            .sorted(by: { $0.rawValue < $1.rawValue })
            .map(\.shortTitle)
            .joined(separator: ", ")
        scheduleView?.setSubtitle(daysString)
        scheduleView?.reloadInputViews()
    }
}

extension TrackerDetailsViewController: CategoriesViewControllerProtocol {
    func categoryDidSelected(for category: String) {
        trackerDraft.category = category
        updateCategoryView(with: category)
        updateSaveButtonState()
    }
    
    private func updateCategoryView(with category: String) {
        categoryView?.setSubtitle(category)
        categoryView?.reloadInputViews()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == emojiCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojisCollectionViewCell.reusedIdentifier, for: indexPath) as? EmojisCollectionViewCell
            
            guard let cell else { return UICollectionViewCell() }
            cell.configure(with: Constants.emojis, index: indexPath.row)
            return cell
            
        } else if collectionView == colorCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCollectionViewCell.reusedIdentifier, for: indexPath) as? ColorsCollectionViewCell
            
            guard let cell else { return UICollectionViewCell() }
            let colors: [UIColor] = TrackerColor.allCases.map({$0.uiColor})
            cell.configure(with: colors, index: indexPath.row)
            return cell
            
        } else { return UICollectionViewCell() }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        if collectionView == emojiCollection {
            if let previous = selectedEmojiIndexPath {
                collectionView.deselectItem(at: previous, animated: false)
            }

            selectedEmojiIndexPath = indexPath
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        } else if collectionView == colorCollection {
            if let previous = selectedColorIndexPath {
                collectionView.deselectItem(at: previous, animated: false)
            }
            
            selectedColorIndexPath = indexPath
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
}
