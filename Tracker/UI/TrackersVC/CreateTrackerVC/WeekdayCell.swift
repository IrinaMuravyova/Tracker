//
//  WeekdayCell.swift
//  Tracker
//
//  Created by Irina Muravyeva on 11.04.2026.
//

import UIKit

class WeekdayCell: UITableViewCell {
    static let reusedIdentifier = "WeekdayCell"
    private let dayLabel = UILabel()
    private let isSelectedSwitch = UISwitch()
    private let separator = UIView()
    
    private var currentDay: Weekday?

    var onToggle: ((Weekday, Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .backgroundDay
        setupUI()
        setupConstraints()
        
        isSelectedSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("[WeekdayCell] init(coder:) has not been implemented")
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        guard let day = currentDay else { return }
        onToggle?(day, sender.isOn)
    }
    
    func configure(with index: IndexPath.Index, isOn: Bool) {
        currentDay = Weekday.allCases[index]
        
        guard let currentDay else { return }
        dayLabel.text = "\(currentDay.title)"
        isSelectedSwitch.isOn = isOn
        
        if index == 0 {
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            contentView.layer.cornerRadius = 16
        } else if index == Weekday.allCases.count - 1 {
            contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            contentView.layer.cornerRadius = 16
            separator.isHidden = true
        }
        
        selectionStyle = .none
    }
}

private extension WeekdayCell {
    func setupUI() {
        dayLabel.font = .systemFont(ofSize: 17, weight: .regular)
        dayLabel.textColor = .blackDay
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayLabel)
        
        isSelectedSwitch.backgroundColor = .clear
        isSelectedSwitch.tintColor = .tintSwitch
        isSelectedSwitch.onTintColor = .onTintSwitch
        isSelectedSwitch.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(isSelectedSwitch)
        
        separator.backgroundColor = .lightGray
        contentView.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            dayLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -22),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            isSelectedSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            isSelectedSwitch.leadingAnchor.constraint(equalTo: dayLabel.trailingAnchor, constant: 16),
            isSelectedSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
