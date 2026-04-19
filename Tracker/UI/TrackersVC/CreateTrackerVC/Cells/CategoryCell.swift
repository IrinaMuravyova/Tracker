//
//  CategoryCell.swift
//  Tracker
//
//  Created by Irina Muravyeva on 15.04.2026.
//

import UIKit

class CategoryCell: UITableViewCell {
    static let reusedIdentifier = "CategoryCell"
    
    private let categoryLabel = UILabel()
    private let selectionImageView = UIImageView ()
    private let separator = UIView()
    
    private var categoryTitle: String = ""
    private var trackersFactory: TrackersFactoryProtocol?
    
    // MARK: - Initializes
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .backgroundDay
        
        trackersFactory = TrackersFactory.shared
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("[CategoryCell] init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func configureDefault() {
        categoryTitle = "Важное"
        categoryLabel.text = categoryTitle
        selectionImageView.image = UIImage(systemName: "checkmark")
        
        contentView.layer.maskedCorners = [
            .layerMinXMinYCorner, .layerMaxXMinYCorner,
            .layerMinXMaxYCorner, .layerMaxXMaxYCorner
        ]
            contentView.layer.cornerRadius = 16
            separator.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            selectionImageView.image = UIImage(systemName: "checkmark")
        } else {
            selectionImageView.image = UIImage()
        }
    }
    
    func getCategoryTitle() -> String {
        return categoryTitle
    }
}

// MARK: - Private methods
private extension CategoryCell {
    func setupUI() {
        selectionStyle = .none
        
        categoryLabel.font = .systemFont(ofSize: 17, weight: .regular)
        categoryLabel.textColor = .blackDay
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryLabel)
        
        selectionImageView.backgroundColor = .clear
        selectionImageView.tintColor = .onTintSwitch
        selectionImageView.image = UIImage()
        selectionImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectionImageView)
        
        separator.backgroundColor = .lightGray
        contentView.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            selectionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionImageView.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 1),
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
