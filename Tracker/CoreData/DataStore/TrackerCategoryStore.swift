//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Irina Muravyeva on 20.04.2026.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    // MARK: - Private properties
    private let context: NSManagedObjectContext

    // MARK: - Initializes
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - CRUD functions
    func addNewCategory(_ category: TrackerCategory) throws {
        let categoriesCoreData = TrackerCategoryCoreData(context: context)
        updateExistingCategory(categoriesCoreData, with: category)
        try context.save()
    }
    
    func deleteCategory(_ category: NSManagedObject) throws {
        context.delete(category)
        try context.save()
    }

    // MARK: - Helper functions
    func updateExistingCategory(_ categoriesCoreData: TrackerCategoryCoreData, with category: TrackerCategory, with trackers: [Tracker]? = nil) {
        categoriesCoreData.title = category.title
    }
}
