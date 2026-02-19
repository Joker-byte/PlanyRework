//
//  CoreDataStack.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import CoreData
import Foundation

final class CoreDataStack {

    static let shared = CoreDataStack()

    private init() {}

    // MARK: - Core Data Stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PlanyStorage")

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("CoreData: Unresolved error \(error), \(error.userInfo)")
                // In production, handle error appropriately
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("CoreData: Persistent store loaded successfully")
                print("Store URL: \(storeDescription.url?.absoluteString ?? "unknown")")
            }
        }

        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Core Data Saving Support

    func saveContext() throws {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("CoreData: Context saved successfully")
            } catch {
                let nsError = error as NSError
                print("CoreData: Failed to save context - \(nsError), \(nsError.userInfo)")
                throw error
            }
        }
    }

    // MARK: - Batch Operations

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }

    // MARK: - Delete All Data

    func deleteAllData() throws {
        let entityNames = [
            "SectionEntity", "TaskEntity", "HomeworkEntity", "ProfileEntity", "SettingEntity",
            "KeyValueEntity",
        ]

        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try viewContext.execute(batchDeleteRequest)
                print("CoreData: Deleted all \(entityName)")
            } catch {
                print("CoreData: Failed to delete \(entityName) - \(error)")
                throw error
            }
        }

        try saveContext()
    }

    // MARK: - Fetch Helpers

    func fetch<T: NSManagedObject>(
        _ entityType: T.Type, predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entityType))
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("CoreData: Failed to fetch \(entityType) - \(error)")
            throw error
        }
    }

    // MARK: - Create Entity

    func createEntity<T: NSManagedObject>(_ entityType: T.Type) -> T {
        return T(context: viewContext)
    }

    // MARK: - Delete Entity

    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
    }
}
