//
//  TrackersCell.swift
//  Tracker
//
//  Created by Irina Muravyeva on 06.04.2026.
//

import UIKit

protocol TrackersCellDelegate: AnyObject {
    func didTapAddButton(in cell: TrackersCell)
}

final class TrackersCell: UICollectionViewCell {
    // MARK: - Public properties
    weak var delegate: TrackersCellDelegate?
    
    // MARK: - UI
    private(set) lazy var habitView = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    
    private let quantityView = UIView()
    private let quantityLabel = UILabel()
    private let addButton = UIButton()
    
    // MARK: - Private properties
    private let emojiSize = 24
    private var currentTrackerId: UUID?
    private var trackerIsDone: Bool = false
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        
        addButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("[TrackersCell] init(coder:) has not been implemented")
    }
    
    // MARK: - Objc methods
    @objc func buttonTapped(_ sender: UIButton) {
        delegate?.didTapAddButton(in: self)
    }
    
    // MARK: - Public functions
    func configureCell(
        with tracker: TrackerUIModel,
        completedCount: Int,
        isDone: Bool
    ) {
        currentTrackerId = tracker.id
        
        let color = tracker.color.uiColor
        habitView.backgroundColor = color
        
        titleLabel.text = tracker.name
        
        let image = isDone
        ? UIImage(resource: .done).withRenderingMode(.alwaysTemplate)
        : UIImage(resource: .plus).withRenderingMode(.alwaysTemplate)
        addButton.setImage(image, for: .normal)
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
        titleLabel.text = "Sample a very long maybe too long habit title"
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
        quantityLabel.text = "0 " + daysString(0)
    }
    
    func setupAddButton(_ isDone: Bool = false) {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        quantityView.addSubview(addButton)
        
        var config = UIButton.Configuration.plain()
        config.image = isDone
        ? UIImage(resource: .done).withRenderingMode(.alwaysTemplate)
        : UIImage(resource: .plus).withRenderingMode(.alwaysTemplate)
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
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("dayString", comment: "Number of marked days for habit"),
            count
        )
        return daysString
    }
}
