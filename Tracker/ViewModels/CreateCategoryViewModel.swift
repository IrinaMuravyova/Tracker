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
            showError?("Введите название категории")
            return
        }

        do {
            try categoryStore.addCategory(trimmedTitle)
            categoryDidCreate?()

        } catch {
            showError?("Такая категория уже существует")
        }
    }
}


