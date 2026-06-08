//
//  CreateCategoryViewModel.swift
//  Tracker
//
//  Created by Irina Muravyeva on 21.05.2026.
//

import Foundation

enum CreateCategoryMode {
    case create
    case edit(oldTitle: String)
}

final class CreateCategoryViewModel {

    // MARK: - Bindings
    var buttonStateDidChange: ((Bool) -> Void)?
    var categoryDidSave: (() -> Void)?
    var showError: ((String) -> Void)?
    var updateNavigationTitle: ((String) -> Void)?

    // MARK: - Private properties
    private let categoryStore: TrackerCategoryStore
    private let mode: CreateCategoryMode
    
    // MARK: - Public properties
    private(set) var categoryTitle: String = ""

    // MARK: - Init
    init(categoryStore: TrackerCategoryStore, mode: CreateCategoryMode = .create) {
        self.categoryStore = categoryStore
        self.mode = mode
    }

    // MARK: - Public methods
    func updateCategoryTitle(_ title: String) {
        categoryTitle = title

        let isValid = !title.trimmingCharacters(in: .whitespaces).isEmpty
        buttonStateDidChange?(isValid)
    }
    
    func saveCategory() {
        let trimmedTitle = categoryTitle.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedTitle.isEmpty else {
            let error = NSLocalizedString(
                "error_message_empty_category",
                comment: "Text displayed error's description about empty category"
            )
            showError?(error)
            return
        }
        
        switch mode {
        case .create:
            createCategory(title: trimmedTitle)
        case .edit(let category):
            do {
                guard let categoryCD = try categoryStore.getCategory(by: category) else {
                    assertionFailure("[CreateCategoryViewModel] Category not transform category title to CategoryCD")
                    return
                }
                editCategory(category: categoryCD, newTitle: trimmedTitle)
            } catch {
                print("[CreateCategoryViewModel] Error getting category: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func setupForMode() {
        switch mode {
        case .create:
            updateNavigationTitle?(
                NSLocalizedString(
                    "createcategory_navigationbar_title",
                    comment: "Text for create category navigation bar title"
                )
            )
            
        case .edit(let oldTitle):
            updateNavigationTitle?(
                NSLocalizedString(
                    "editcategory_navigationbar_title",
                    comment: "Text for edit category navigation bar title"
                )
            )
            
            categoryTitle = oldTitle
            buttonStateDidChange?(true)
        }
    }
}

// MARK: - Private methods
private extension CreateCategoryViewModel {
    func createCategory(title: String) {
        do {
            try categoryStore.addCategory(title)
            categoryDidSave?()

        } catch {
            let error = NSLocalizedString(
                "error_message_category_exist",
                comment: "Text displayed error's description about already existed category"
            )
            
            showError?(error)
        }
    }
    
    func editCategory(category: TrackerCategoryCoreData, newTitle: String) {
        guard let oldTitle = category.title, oldTitle != newTitle else {
            categoryDidSave?()
            return
        }
 
        do {
            try categoryStore.updateCategory(category, newTitle: newTitle)
            categoryDidSave?()
        } catch {
            let error = NSLocalizedString(
                "error_message_category_update_failed",
                comment: "Text displayed error's description about update failure"
            )
            showError?(error)
        }
    }
}
