//
//  CreateCategoryViewModel.swift
//  Tracker
//
//  Created by Irina Muravyeva on 21.05.2026.
//

import Foundation

final class CreateCategoryViewModel {

    // MARK: - Bindings
    var buttonStateDidChange: ((Bool) -> Void)?
    var categoryDidCreate: (() -> Void)?
    var showError: ((String) -> Void)?

    // MARK: - Private properties
    private let categoryStore: TrackerCategoryStore

    // MARK: - Public properties
    private(set) var categoryTitle: String = ""

    // MARK: - Init
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
    }

    // MARK: - Public methods
    func updateCategoryTitle(_ title: String) {
        categoryTitle = title

        let isValid = !title.trimmingCharacters(in: .whitespaces).isEmpty

        buttonStateDidChange?(isValid)
    }

    func createCategory() {

        let trimmedTitle = categoryTitle
            .trimmingCharacters(in: .whitespaces)

        guard !trimmedTitle.isEmpty else {
            let error = NSLocalizedString(
                "error_message_empty_category",
                comment: "Text displayed error's description about empty category"
            )
            
            showError?(error)
            return
        }

        do {
            try categoryStore.addCategory(trimmedTitle)
            categoryDidCreate?()

        } catch {
            let error = NSLocalizedString(
                "error_message_category_exist",
                comment: "Text displayed error's description about already existed category"
            )
            
            showError?(error)
        }
    }
}


