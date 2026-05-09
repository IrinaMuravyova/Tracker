//
//  TrackerFetchedResultsController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 06.05.2026.
//

import CoreData

// MARK: - TrackerFetchedResultsControllerProtocol
protocol TrackerFetchedResultsControllerProtocol {
    var numberOfSections: Int { get }
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackerCoreData
    func performFetch() throws
    func titleForSection(_ section: Int) -> String
    
    var delegate: TrackerFetchedResultsControllerDelegate? { get set }
}

// MARK: - TrackerFetchedResultsControllerDelegate
protocol TrackerFetchedResultsControllerDelegate: AnyObject {
    func trackerStoreDidChangeContent()
}

final class TrackerFetchedResultsController: NSObject {
    // MARK: - Private properties
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil)
         
        return fetchedResultsController
    }()
        
    private let context: NSManagedObjectContext
    
    // MARK: - Public properties
    weak var delegate: TrackerFetchedResultsControllerDelegate?

    // MARK: - Initializes
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        fetchedResultsController.delegate = self
    }
}

// MARK: - Public functions
extension TrackerFetchedResultsController: TrackerFetchedResultsControllerProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCoreData {
        fetchedResultsController.object(at: indexPath)
    }
    
    func performFetch() throws {
           try fetchedResultsController.performFetch()
       }
    
    func titleForSection(_ section: Int) -> String {
        fetchedResultsController.sections?[section].name ?? ""
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerFetchedResultsController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidChangeContent()
    }
}
