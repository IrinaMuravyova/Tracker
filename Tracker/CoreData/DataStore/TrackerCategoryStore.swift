//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Irina Muravyeva on 20.04.2026.
//

import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    // MARK: - Private properties
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        frc.delegate = self
        return frc
    }()
    
    // MARK: - Bindings
    var onChange: (() -> Void)?

    // MARK: - Initializes
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        try? fetchedResultsController.performFetch()
    }
    
    // MARK: - Public FRC access
    var categories: [TrackerCategoryCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }

    func controller() -> NSFetchedResultsController<TrackerCategoryCoreData> {
        fetchedResultsController
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
    
    func deleteCategory(_ category: TrackerCategoryCoreData) throws {
        if let trackers = category.tracker, trackers.count > 0 {
            throw NSError(
                domain: "TrackerCategoryStore",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Cannot delete category that contains trackers"]
            )
        }
        
        context.delete(category)
        try context.save()
    }
    
    func fetchCategory(by title: String) throws -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            throw NSError(
                domain: "TrackerCategoryStore",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Failed to fetch category by title: \(title)"]
            )
        }
    }
    
    func getCategory(for trackerID: UUID) throws -> TrackerCategoryCoreData? {
        let trackerRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        trackerRequest.fetchLimit = 1
        
        do {
            let trackers = try context.fetch(trackerRequest)
            guard let tracker = trackers.first else { return nil }

            return tracker.category
        } catch {
            throw NSError(
                domain: "TrackerCategoryStore",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Failed to get category for tracker with id: \(trackerID)"]
            )
        }
    }
    
    func getCategoryTitle(for trackerID: UUID) -> String {
        do {
            guard let category = try getCategory(for: trackerID) else { return "" }
            return category.title ?? ""
        } catch {
            print("[TrackerCategoryStore] Error getting category title for tracker \(trackerID): \(error.localizedDescription)")
            return ""
        }
    }
    
    func getCategory(by title: String) throws -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        
        do {
            let categories = try context.fetch(request)
            return categories.first
        } catch {
            throw NSError(
                domain: "TrackerCategoryStore",
                code: 409,
                userInfo: [NSLocalizedDescriptionKey: "Category with this name already exists"]
            )
        }
    }
    
    func updateCategory(_ category: TrackerCategoryCoreData, newTitle: String) throws {
        let categoryExists = categoryExists(with: newTitle)
        
        if categoryExists {
            throw NSError(
                domain: "TrackerCategoryStore",
                code: 409,
                userInfo: [NSLocalizedDescriptionKey: "Category with this name already exists"]
            )
        }
        
        category.title = newTitle
        try context.save()
    }
    
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

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        onChange?()
    }
}
