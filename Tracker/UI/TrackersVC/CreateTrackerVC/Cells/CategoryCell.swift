//
//  CategoryCell.swift
//  Tracker
//
//  Created by Irina Muravyeva on 15.04.2026.
//

import UIKit

protocol CategoryCellDelegate: AnyObject {
    func categoryDidUpdate(with title: String)
}

class CategoryCell: UITableViewCell {
    // MARK: - Static properties
    static let reusedIdentifier = "CategoryCell"

    // MARK: - UI Properties
    private let categoryTextField = UITextField()
    private let selectionImageView = UIImageView ()
    private let separator = UIView()
    
    // MARK: - Private properties
    private var trackersFactory: TrackersFactoryProtocol?
    
    // MARK: - Public properties
    weak var delegate: CategoryCellDelegate?
    
    // MARK: - Initializes
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .backgroundDay

        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("[CategoryCell] init(coder:) has not been implemented")
    }
    
    // MARK: - Override methods
    override func setSelected(_ selected: Bool, animated: Bool) {
        guard !categoryTextField.isEnabled else {
            selectionImageView.isHidden = true
            return
        }
        
        if selected {
            selectionImageView.image = UIImage(systemName: "checkmark")
        } else {
            selectionImageView.image = UIImage()
        }
    }
    
    // MARK: - Objective-C methods
    @objc private func titleDidChange(_ textField: UITextField) {
        let category = textField.text ?? ""
        delegate?.categoryDidUpdate(with: category)
    }
    
    // MARK: - Public methods
    func configureDefault(container: CoreDataContainer) {
        trackersFactory = TrackerRepository(container: container)
        
        categoryTextField.placeholder = "Введите название категории"
        selectionImageView.image = UIImage(systemName: "checkmark")
        
        contentView.layer.maskedCorners = [
            .layerMinXMinYCorner, .layerMaxXMinYCorner,
            .layerMinXMaxYCorner, .layerMaxXMaxYCorner
        ]
            contentView.layer.cornerRadius = 16
            separator.isHidden = true
    }
    
    func configure(with category: TrackerCategory, container: CoreDataContainer) {
        configureDefault(container: container)
        categoryTextField.text = category.title
        
        categoryTextField.isEnabled = false
        selectionImageView.isHidden = false
    }
    
    func getCategoryTitle() -> String {
        guard let title = categoryTextField.text else {
            print("[CategoryCell] categoryTextField.text is not String ")
            return ""
        }
        return title
    }
}

// MARK: - Private methods
private extension CategoryCell {
    func setupUI() {
        selectionStyle = .none
        
        setupCategoryTF()
        setupSelectionIV()
        setupSeparator()
    }
    
    func setupCategoryTF() {
        categoryTextField.font = .systemFont(ofSize: 17, weight: .regular)
        categoryTextField.textColor = .blackDay
        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryTextField)
        
        categoryTextField.becomeFirstResponder()
        
        categoryTextField.addTarget(self, action: #selector(titleDidChange(_:)), for: .editingChanged)
    }
    
    func setupSelectionIV() {
        selectionImageView.backgroundColor = .clear
        selectionImageView.tintColor = .onTintSwitch
        selectionImageView.image = UIImage()
        selectionImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectionImageView)
        
        selectionImageView.isHidden = categoryTextField.isEnabled
    }
    
    func setupSeparator() {
        separator.backgroundColor = .lightGray
        contentView.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            categoryTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            selectionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            selectionImageView.leadingAnchor.constraint(equalTo: categoryTextField.trailingAnchor, constant: 1),
            selectionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            selectionImageView.heightAnchor.constraint(equalToConstant: 24),
            selectionImageView.widthAnchor.constraint(equalToConstant: 24),
            
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
