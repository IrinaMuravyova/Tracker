//
//  EmojisCollectionViewCell.swift
//  Tracker
//
//  Created by Irina Muravyeva on 17.04.2026.
//

import UIKit

final class EmojisCollectionViewCell: UICollectionViewCell {
    // MARK: - Static properties
    static let reusedIdentifier = "emojiCell"
    
    // MARK: - Private properties
    private let emojiLabel = UILabel()
    
    // MARK: - Public properties
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected
                ? .lightGray.withAlphaComponent(0.3)
                : .clear
        }
    }
    
    // MARK: - Initializes
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("[EmojisCollectionViewCell] init(coder:) has not been implemented")
    }
    
    // MARK: - Public functions
    func configure(with emojis: [String], index: Int) {
        emojiLabel.text = emojis[index] 
    }
}

// MARK: - Private functions
private extension EmojisCollectionViewCell {
    func setupCell() {
        setupEmojiLabel()
        setupConstraints()
    }
    
    func setupEmojiLabel() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        
        emojiLabel.font = .systemFont(ofSize: 32)
        contentView.layer.cornerRadius = 16
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
