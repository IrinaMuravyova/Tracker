//
//  TrackerDetailsViewController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 09.04.2026.
//

import UIKit

final class TrackerDetailsViewController: UIViewController {
    // MARK: - UI
    private let titleTF = UITextField()
    private var detailsStackView = UIStackView()
    private var categoryView = UIView()
    private var scheduleView = UIView()
    private var buttonStackView = UIStackView()
    private let cancelButton = UIButton()
    private let saveButton = UIButton()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size.height = 1
        return view
    }()
    
    // MARK: - Private properties
    private let trackerType: TrackerType
    
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
        print("tracker type = ", trackerType)
        let isHabit = trackerType == .habit
        title = isHabit
            ? "Новая привычка"
            : "Новое нерегулярное событие"
        
        saveButton.isEnabled = false
        setupUI()
        scheduleView.isHidden = trackerType != .habit
        
        if !isHabit {
            scheduleView.isHidden = true
            separator.isHidden = true
        }
        
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Selectors
    @objc private func cancelButtonDidTap() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonDidTap() {
        
    }
}

// MARK: - Private methods
private extension TrackerDetailsViewController {
    func setupUI() {
        setupTitleTF()
        setupDetailsView()
        setupButtons()
        setupConstraints()
    }

    func setupTitleTF() {
        titleTF.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleTF)
        
        titleTF.placeholder = "Введите название трекера"
        titleTF.layer.cornerRadius = 16
        titleTF.backgroundColor = .backgroundDay
        view.layer.cornerRadius = 16
        
        titleTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        titleTF.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))

        titleTF.leftViewMode = .always
        titleTF.rightViewMode = .always
    }
    
    func setupDetailsView() {
        categoryView = BaseDetailsItem(
            withTitle: "Категория",
            subTitle: ""//"Важное"
        )
     
        scheduleView = BaseDetailsItem(
            withTitle: "Расписание",
            subTitle: ""//"Пн,Ср,Пт"
        )

        detailsStackView = UIStackView(
            arrangedSubviews: [categoryView, separator,  scheduleView]
        )
        detailsStackView.axis = .vertical
        detailsStackView.alignment = .fill
        detailsStackView.distribution = .fillProportionally
        detailsStackView.backgroundColor = .backgroundDay
        detailsStackView.layer.cornerRadius = 16

        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailsStackView)
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
        saveButton.backgroundColor = saveButton.isEnabled ? .blackDay : .gray
        saveButton.layer.cornerRadius = 16
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTF.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleTF.heightAnchor.constraint(equalToConstant: 75),
            
            separator.leadingAnchor.constraint(equalTo: detailsStackView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: detailsStackView.trailingAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            detailsStackView.topAnchor.constraint(equalTo: titleTF.bottomAnchor, constant: 24),
            detailsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 161),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.widthAnchor.constraint(equalToConstant: 161),
            
            buttonStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}
