//
//  StatisticsCell.swift
//  Tracker
//
//  Created by Irina Muravyeva on 26.05.2026.
//

import UIKit

class StatisticsCell: UICollectionViewCell {
    static let identifier = "StatisticCell"
    
    // MARK: - UI
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .blackDay
        label.textAlignment = .left
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .blackDay
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override methods
    override func layoutSubviews() {
        super.layoutSubviews()
        addGradientBorder()
    }
    
    // MARK: - Public methods
    func configure(value: Int, title: String) {
        valueLabel.text = "\(value)"
        titleLabel.text = title
    }
}

// MARK: - Private methods
private extension StatisticsCell {
    func setupUI() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(valueLabel)
        containerView.addSubview(titleLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func addGradientBorder() {
        layer.sublayers?.removeAll(where: { $0 is CAGradientLayer && $0.name == "gradientBorder" })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradientBorder"
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 16
        gradientLayer.colors = [
            UIColor(named: "gradientStart")?.cgColor ?? UIColor.red.cgColor,
            UIColor(named: "gradientMiddle")?.cgColor ?? UIColor.green.cgColor,
            UIColor(named: "gradientEnd")?.cgColor ?? UIColor.blue.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let maskLayer = CAShapeLayer()
        let outerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16)
        let innerPath = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 2), cornerRadius: 14)
        outerPath.append(innerPath.reversing())
        
        maskLayer.path = outerPath.cgPath
        maskLayer.fillRule = .evenOdd
        gradientLayer.mask = maskLayer
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
