//
//  ColorsCollectionViewCell.swift
//  Tracker
//
//  Created by Irina Muravyeva on 18.04.2026.
//

import UIKit

final class ColorsCollectionViewCell: UICollectionViewCell {
    // MARK: - Static properties
    static let reusedIdentifier = "colorCell"
    
    // MARK: - Private properties
    private let colorView = UIView()
    private let borderView = UIView()
    
    // MARK: - Public properties
    override var isSelected: Bool {
        didSet {
            if isSelected {
                borderView.layer.borderWidth = 3
                let currentColor = self.colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
                borderView.layer.borderColor = currentColor
            } else {
                borderView.layer.borderWidth = 0
                borderView.layer.borderColor = .none
            }
        }
    }
    
    // MARK: - Initializes
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("[ColorsCollectionViewCell] init(coder:) has not been implemented")
    }
    
    // MARK: - Public functions
    func configure(with colors: [UIColor], index: Int) {
        colorView.backgroundColor = colors[index]
    }
}

// MARK: - Private functions
private extension ColorsCollectionViewCell {
    func setupCell() {
        setupBorderView()
        setupColorView()
        setupConstraints()
    }
    
    func setupBorderView() {
        borderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(borderView)
        borderView.layer.cornerRadius = 8
    }
    
    func setupColorView() {
        colorView.translatesAutoresizingMaskIntoConstraints = false
        borderView.addSubview(colorView)
        colorView.layer.cornerRadius = 8
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            borderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            borderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            borderView.widthAnchor.constraint(equalToConstant: 49),
            borderView.heightAnchor.constraint(equalToConstant: 49),
            
            colorView.centerXAnchor.constraint(equalTo: borderView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: borderView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
