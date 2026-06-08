//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Irina Muravyeva on 21.05.2026.
//

import Foundation

enum CategoriesViewMode {
    case selection
    case editing
}

final class CategoriesViewModel {
    // MARK: - Bindings
    var categoriesDidChange: (() -> Void)?
    var selectedCategoryDidChange: ((String) -> Void)?

    // MARK: - Private properties
    private let categoryStore: TrackerCategoryStore
    private let mode: CategoriesViewMode

    // MARK: - Public properties
    private(set) var selectedCategory: String?
    
    var categories: [TrackerCategoryCoreData] {
        categoryStore.categories
    }
    
    var isEmpty: Bool {
        categories.isEmpty
    }

    var numberOfCategories: Int {
        categories.count
    }

    // MARK: - Initializes
    init(categoryStore: TrackerCategoryStore, mode: CategoriesViewMode = .selection) {
        self.categoryStore = categoryStore
        self.mode = mode
        bind()
    }
    
    // MARK: - Private methods
    private func bind() {
        categoryStore.onChange = { [weak self] in
            self?.categoriesDidChange?()
        }
    }
}

// MARK: - Public methods
extension CategoriesViewModel {
    func selectCategory(at index: Int) {
        guard index < categories.count,
              let category = categories[index].title
        else { return }
        
        selectedCategory = category
        selectedCategoryDidChange?(category)
    }
    
    func category(at index: Int) -> TrackerCategoryCoreData {
        categories[index]
    }
    
    func setSelectedCategory(_ category: String?) {
        selectedCategory = category
        
        guard let selectedCategory else { return }
        selectedCategoryDidChange?(selectedCategory)
    }
    
    func makeCreateCategoryViewModel() -> CreateCategoryViewModel {
        CreateCategoryViewModel(categoryStore: categoryStore)
    }
    
    func makeEditCategoryViewModel(at index: Int) -> CreateCategoryViewModel? {
        guard index < categories.count else { return nil }
        
        let category = categories[index]
        guard let categoryTitle = category.title else { return nil }

        return CreateCategoryViewModel(categoryStore: categoryStore, mode: .edit(oldTitle: categoryTitle))
    }

    func deleteCategory(at index: Int) {
        let categoryToDelete = categories[index]
        let categoryTitle = categoryToDelete.title ?? ""
        
        let wasSelected = (selectedCategory == categoryTitle)
        
        do {
            try categoryStore.deleteCategory(categoryToDelete)
            if wasSelected {
                selectedCategory = nil
            }
        } catch {
            let errorMessage: String
            if (error as NSError).code == 400 {
                errorMessage = NSLocalizedString(
                    "category_delete_not_empty",
                    comment: "Error when deleting category with trackers"
                )
            } else {
                errorMessage = NSLocalizedString(
                    "category_delete_failed",
                    comment: "Generic category deletion error"
                )
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("CategoryDeletionError"),
                    object: nil,
                    userInfo: ["message": errorMessage]
                )
            }
            
            assertionFailure("[CategoryViewModel] \(errorMessage)")
        }
    }
}
