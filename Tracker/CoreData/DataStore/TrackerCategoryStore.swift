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
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - CRUD functions
    func addCategory(_ category: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category)
        
        let existingCategories = try context.fetch(request)
        
        if existingCategories.isEmpty {
            let categoryCoreData = TrackerCategoryCoreData(context: context)
            categoryCoreData.title = category
            try context.save()
            
        } else {
            throw NSError(
                domain: "TrackerCategoryStore",
                code: 409,
                userInfo: [NSLocalizedDescriptionKey: "Category already exists"]
            )
        }
    }
    
    func deleteCategory(_ category: NSManagedObject) throws {
        context.delete(category)
        try context.save()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let existingCategories = try context.fetch(request)
            
            let categories = existingCategories.map { coreDataCategory in
                TrackerCategory(
                    title: coreDataCategory.title ?? "Без названия",
                    trackers: []
                )
            }
            return categories
        } catch {
            print("[TrackerCategoryStore] fetchCategories failed with error: \(error)")
            return []
        }
    }
    
    func fetchCategory(by title: String) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("[TrackerCategoryStore] fetchCategory(by:) failed with error: \(error)")
            return nil
        }
    }
    
    // Helpers
    func categoryExists(with title: String) -> Bool {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
}
