//
//  AppDelegate.swift
//  Tracker
//
//  Created by Irina Muravyeva on 26.03.2026.
//

import UIKit
import CoreData

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
#if DEBUG
                fatalError("Unresolved error \(error), \(error.userInfo)")
#else
                print("Core Data error: \(error), \(error.userInfo)")
#endif
            }
        })
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
#if DEBUG
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
#else
                print("Unresolved error \(nsError), \(nsError.userInfo)")
#endif
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveContext()
    }
}

