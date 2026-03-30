//
//  TrackersViewCoontroller.swift
//  Tracker
//
//  Created by Irina Muravyeva on 30.03.2026.
//

import UIKit

class TrackersViewController: UIViewController {
    var titleLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad( )
        setupNavButton()
        setupTitle()
    }
}

private extension TrackersViewController {
    func setupNavButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: nil,
            action: nil)
    }
    
    func setupTitle() {
        titleLabel = UILabel()
        guard let titleLabel else { return }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -105)
        ])
    }
}
