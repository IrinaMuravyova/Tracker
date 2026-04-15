//
//  SupplementaryView.swift
//  Tracker
//
//  Created by Irina Muravyeva on 07.04.2026.
//

import UIKit

final class SupplementaryView: UICollectionReusableView {
    // MARK: - Static constants
    static let reuseHeaderId = "SupplementaryView"
    
    // MARK: - Private UI
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    // MARK: - Initializes
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("[SupplementaryView] init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func configure(title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Private methods
    private func setupViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6)
        ])
    }
}
