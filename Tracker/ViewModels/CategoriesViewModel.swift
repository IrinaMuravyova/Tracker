//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Irina Muravyeva on 21.05.2026.
//

import Foundation

final class CategoriesViewModel {
    // MARK: - Bindings
    var categoriesDidChange: (() -> Void)?
    var selectedCategoryDidChange: ((String) -> Void)?

    // MARK: - Private properties
    private let categoryStore: TrackerCategoryStore

    // MARK: - Public properties
    private(set) var categories: [TrackerCategory] = []
    private(set) var selectedCategory: String?
    
    var isEmpty: Bool {
        categories.isEmpty
    }

    var numberOfCategories: Int {
        categories.count
    }

    // MARK: - Initializes
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
    }
}

// MARK: - Public functions
extension CategoriesViewModel {
    func fetchCategories() {
        categories = categoryStore.fetchCategories()
        categoriesDidChange?()
    }
    
    func selectCategory(at index: Int) {
        let category = categories[index].title
        selectedCategory = category
        selectedCategoryDidChange?(category)
    }
    
    func category(at index: Int) -> TrackerCategory {
        categories[index]
    }
    
    func makeCreateCategoryViewModel() -> CreateCategoryViewModel {
        CreateCategoryViewModel(categoryStore: categoryStore)
    }
}
