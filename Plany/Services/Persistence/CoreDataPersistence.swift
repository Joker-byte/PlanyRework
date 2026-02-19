//
//  CoreDataPersistence.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import CoreData
import Foundation

final class CoreDataPersistence: PersistenceProtocol {

    private let stack = CoreDataStack.shared

    // MARK: - Generic Codable Save/Load

    func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else {
            print("CoreData: Failed to encode value for key: \(key)")
            return
        }
        saveData(data, forKey: key)
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = loadData(forKey: key) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("CoreData: Failed to decode \(type) for key: \(key) - \(error)")
            return nil
        }
    }

    // MARK: - String Operations

    func saveString(_ value: String, forKey key: String) {
        do {
            // Find existing or create new
            let predicate = NSPredicate(format: "key == %@", key)
            let existing = try stack.fetch(KeyValueEntity.self, predicate: predicate).first

            let entity = existing ?? stack.createEntity(KeyValueEntity.self)
            entity.key = key
            entity.valueString = value
            entity.valueData = nil
            entity.valueBool = false

            try stack.saveContext()
            print("CoreData: Saved string for key: \(key)")
        } catch {
            print("CoreData: Failed to save string for key: \(key) - \(error)")
        }
    }

    func loadString(forKey key: String) -> String? {
        do {
            let predicate = NSPredicate(format: "key == %@", key)
            let entity = try stack.fetch(KeyValueEntity.self, predicate: predicate).first
            return entity?.valueString
        } catch {
            print("CoreData: Failed to load string for key: \(key) - \(error)")
            return nil
        }
    }

    // MARK: - Data Operations

    func saveData(_ value: Data, forKey key: String) {
        do {
            // Find existing or create new
            let predicate = NSPredicate(format: "key == %@", key)
            let existing = try stack.fetch(KeyValueEntity.self, predicate: predicate).first

            let entity = existing ?? stack.createEntity(KeyValueEntity.self)
            entity.key = key
            entity.valueData = value
            entity.valueString = nil
            entity.valueBool = false

            try stack.saveContext()
            print("CoreData: Saved data for key: \(key) (\(value.count) bytes)")
        } catch {
            print("CoreData: Failed to save data for key: \(key) - \(error)")
        }
    }

    func loadData(forKey key: String) -> Data? {
        do {
            let predicate = NSPredicate(format: "key == %@", key)
            let entity = try stack.fetch(KeyValueEntity.self, predicate: predicate).first
            return entity?.valueData
        } catch {
            print("CoreData: Failed to load data for key: \(key) - \(error)")
            return nil
        }
    }

    // MARK: - Bool Operations

    func saveBool(_ value: Bool, forKey key: String) {
        do {
            // Find existing or create new
            let predicate = NSPredicate(format: "key == %@", key)
            let existing = try stack.fetch(KeyValueEntity.self, predicate: predicate).first

            let entity = existing ?? stack.createEntity(KeyValueEntity.self)
            entity.key = key
            entity.valueBool = value
            entity.valueString = nil
            entity.valueData = nil

            try stack.saveContext()
            print("CoreData: Saved bool for key: \(key) = \(value)")
        } catch {
            print("CoreData: Failed to save bool for key: \(key) - \(error)")
        }
    }

    func loadBool(forKey key: String) -> Bool {
        do {
            let predicate = NSPredicate(format: "key == %@", key)
            let entity = try stack.fetch(KeyValueEntity.self, predicate: predicate).first
            return entity?.valueBool ?? false
        } catch {
            print("CoreData: Failed to load bool for key: \(key) - \(error)")
            return false
        }
    }

    // MARK: - Remove Operations

    func remove(forKey key: String) {
        do {
            let predicate = NSPredicate(format: "key == %@", key)
            let entities = try stack.fetch(KeyValueEntity.self, predicate: predicate)

            for entity in entities {
                stack.delete(entity)
            }

            try stack.saveContext()
            print("CoreData: Removed key: \(key)")
        } catch {
            print("CoreData: Failed to remove key: \(key) - \(error)")
        }
    }

    func removeAll(forKeys keys: [String]) {
        do {
            for key in keys {
                let predicate = NSPredicate(format: "key == %@", key)
                let entities = try stack.fetch(KeyValueEntity.self, predicate: predicate)

                for entity in entities {
                    stack.delete(entity)
                }
            }

            try stack.saveContext()
            print("CoreData: Removed \(keys.count) keys")
        } catch {
            print("CoreData: Failed to remove keys - \(error)")
        }
    }
}
