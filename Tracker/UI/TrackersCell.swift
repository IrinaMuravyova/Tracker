//
//  TrackersCell.swift
//  Tracker
//
//  Created by Irina Muravyeva on 06.04.2026.
//

import UIKit

class TrackersCell: UICollectionViewCell {
    // MARK: - UI
    private let habitView = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    
    private let quantityView = UIView()
    private let quantityLabel = UILabel()
    private let addButton = UIButton()
    
    // MARK: - Private properties
    private let emojiSize = 24
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("[TrackersCell] init(coder:) has not been implemented")
    }
    
    func configureCell(with tracker: Tracker, completedCount: Int) {
        let color = tracker.color.uiColor
        habitView.backgroundColor = color
        
        guard var config = addButton.configuration else { return }
        config.baseForegroundColor = color
        addButton.configuration = config
        
        emojiLabel.text = tracker.emoji
        quantityLabel.text = "\(daysString(completedCount))"
    }
}

// MARK: - Private functions
private extension TrackersCell {
    func configure() {
        setupHabitView()
        setupQuantityView()
        setupConstraints()
    }
    
    func setupHabitView() {
        habitView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(habitView)
        
        habitView.layer.cornerRadius = 16
 
        setupEmoji()
        setupLabel()
    }
    
    func setupQuantityView() {
        self.quantityView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(quantityView)
        
        setupQuantityLabel()
        setupAddButton()
    }
    
    func setupConstraints() {
        setupHabitViewConstraints()
        setupQuantityViewConstraints()
    }
    
    func setupEmoji() {
        emojiLabel.frame.size = CGSize(width: emojiSize, height: emojiSize)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        habitView.addSubview(emojiLabel)
    }
    
    func setupLabel() {
        titleLabel.text = "Текст привычки такой длинный текст"
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        habitView.addSubview(titleLabel)
    }
    
    func setupHabitViewConstraints() {
        NSLayoutConstraint.activate([
            habitView.topAnchor.constraint(equalTo: contentView.topAnchor),
            habitView.heightAnchor.constraint(equalToConstant: 90),
            habitView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            habitView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: habitView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: habitView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: CGFloat(emojiSize)),
            emojiLabel.heightAnchor.constraint(equalToConstant: CGFloat(emojiSize)),
            
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: habitView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: habitView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: habitView.bottomAnchor, constant: -12)
        ])
    }
    
    func setupQuantityLabel() {
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityView.addSubview(quantityLabel)
        
        quantityLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        quantityLabel.textAlignment = .center
        quantityLabel.text = "0 дней"
    }
    
    func setupAddButton() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        quantityView.addSubview(addButton)
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(resource: .plus).withRenderingMode(.alwaysTemplate)        
        addButton.configuration = config
    }
    
    func setupQuantityViewConstraints() {
        NSLayoutConstraint.activate([
            quantityView.topAnchor.constraint(equalTo: habitView.bottomAnchor),
            quantityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quantityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quantityView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            quantityLabel.topAnchor.constraint(equalTo: quantityView.topAnchor, constant: 12),
            quantityLabel.bottomAnchor.constraint(equalTo: quantityView.bottomAnchor, constant: -24),
            quantityLabel.leadingAnchor.constraint(equalTo: quantityView.leadingAnchor, constant: 16),
            quantityLabel.rightAnchor.constraint(equalTo: addButton.leftAnchor, constant: -54),
            
            addButton.topAnchor.constraint(equalTo: quantityView.topAnchor, constant: 8),
            addButton.bottomAnchor.constraint(equalTo: quantityView.bottomAnchor, constant: -16),
            addButton.trailingAnchor.constraint(equalTo: quantityView.trailingAnchor, constant: 0),
        ])
    }
    
    func daysString(_ count: Int) -> String {
        let remainder100 = count % 100
        let remainder10 = count % 10
        
        if remainder100 >= 11 && remainder100 <= 14 {
            return "\(count) дней"
        }
        
        switch remainder10 {
        case 1:
            return "\(count) день"
        case 2, 3, 4:
            return "\(count) дня"
        default:
            return "\(count) дней"
        }
    }
}
