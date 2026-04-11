//
//  TrackerDetailsViewController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 09.04.2026.
//

import UIKit

private struct ViewModel {
    var title: String
    var category: String
    var schedule: Set<Weekday>
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
    
    // MARK: - Private properties
    private let trackerType: TrackerType
    private var viewModel = ViewModel(
        title: "",
        category: "",
        schedule: []
    )
    private var scheduleSettingsVC = ScheduleSettingsVC()
    
    // MARK: - Initializes
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
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
        
        scheduleView?.onTap = {
            self.scheduleSettingsVC.title = self.scheduleView?.getTitle()
            self.navigationController?.pushViewController(self.scheduleSettingsVC, animated: true)
        }
        
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
        
        titleTF.addTarget(self, action: #selector(titleDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - Objc methods
    @objc private func cancelButtonDidTap() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonDidTap() {
        //TODO: сохранить в базу в фоне
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func titleDidChange(_ textField: UITextField) {
        viewModel.title = textField.text ?? ""
        updateSaveButtonState()
    }
}

// MARK: - Private methods
private extension TrackerDetailsViewController {
    private func updateSaveButtonState() {
        print("updateSaveButtonState CALLED")
        let isValid: Bool = {
            if trackerType == .habit {
                return !viewModel.title.isEmpty &&
                       !viewModel.category.isEmpty &&
                       !viewModel.schedule.isEmpty
            } else {
                return !viewModel.title.isEmpty &&
                       !viewModel.category.isEmpty
            }
        }()
        
        saveButton.isEnabled = isValid
        saveButtonSetupColors()
    }
}

// MARK: - UI settings methods
private extension TrackerDetailsViewController {
    func setupUI() {
        setupScrollView()
        setupTitleStack()
        setupDetailsView()
        setupButtons()
        setupConstraints()
    }
    
    func setupScrollView() {
        scrollView.alwaysBounceVertical = true
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
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
        
        categoryView?.setSubtitle("Важное")
        viewModel.category = "Важное"
     
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
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70),

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
            detailsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
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
        viewModel.title = text
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - ScheduleSettingsVCProtocol
extension TrackerDetailsViewController: ScheduleSettingsVCProtocol {
    func scheduleDidSetup(for days: Set<Weekday>) {
        viewModel.schedule = days
        updateScheduleView()
        updateSaveButtonState()
    }
    
    private func updateScheduleView() {
        let daysString = viewModel.schedule.count == Weekday.allCases.count
        ? "Каждый день"
        : viewModel.schedule
            .sorted(by: { $0.rawValue < $1.rawValue })
            .map(\.shortTitle)
            .joined(separator: ", ")
        scheduleView?.setSubtitle(daysString)
        scheduleView?.reloadInputViews()
    }
}
