//
//  BaseDetailsItem.swift
//  Tracker
//
//  Created by Irina Muravyeva on 10.04.2026.
//

import UIKit

final class BaseDetailsItem: UIView {
    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .chevron))
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initializes
    init(withTitle: String, subTitle: String) {
        super.init(frame: .zero)
        
        self.titleLabel.text = withTitle
        self.subTitleLabel.text = subTitle
        setupUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("[BaseDetailsItem] init(coder:) has not been implemented")
    }
    
    // MARK: - Objc methods
    @objc private func handleTap() {
        onTap()
    }
    
    // MARK: - Public methods
    var onTap: (() -> Void) = {}
    
    func getTitle() -> String {
        titleLabel.text ?? ""
    }
    
    func setSubtitle(_ text: String) {
        subTitleLabel.text = text
    }
}

// MARK: - UI settings functions
private extension BaseDetailsItem {
    func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 75),
            
            titleLabel.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
//            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subTitleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            subTitleLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 24),
            chevronImageView.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
}
