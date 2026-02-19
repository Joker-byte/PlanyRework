//
//  PersistenceManager.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import Foundation

enum PersistenceType {
    case userDefaults
    case coreData
    case swiftData
}

protocol PersistenceProtocol {
    func save<T: Encodable>(_ value: T, forKey key: String)
    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T?
    func saveString(_ value: String, forKey key: String)
    func loadString(forKey key: String) -> String?
    func saveData(_ value: Data, forKey key: String)
    func loadData(forKey key: String) -> Data?
    func saveBool(_ value: Bool, forKey key: String)
    func loadBool(forKey key: String) -> Bool
    func remove(forKey key: String)
    func removeAll(forKeys keys: [String])
}

final class PersistenceManager {

    static let shared = PersistenceManager()

    private var currentPersistence: PersistenceProtocol

    var persistenceType: PersistenceType = .userDefaults {
        didSet {
            updatePersistence()
        }
    }

    private init() {
        self.currentPersistence = UserDefaultsPersistence()
    }

    private func updatePersistence() {
        switch persistenceType {
        case .userDefaults:
            currentPersistence = UserDefaultsPersistence()
            print("STORAGE: Using UserDefaults")
        case .coreData:
            currentPersistence = CoreDataPersistence()
            print("STORAGE: Using Core Data")
        case .swiftData:
            currentPersistence = SwiftDataPersistence()
            print("STORAGE: Using SwiftData")
        }
    }

    func getCurrentStorageMethodName() -> String {
        switch persistenceType {
        case .userDefaults:
            return "UserDefaults"
        case .coreData:
            return "Core Data"
        case .swiftData:
            return "SwiftData"
        }
    }

    func save<T: Encodable>(_ value: T, forKey key: String) {
        currentPersistence.save(value, forKey: key)
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        return currentPersistence.load(type, forKey: key)
    }

    func saveString(_ value: String, forKey key: String) {
        currentPersistence.saveString(value, forKey: key)
    }

    func loadString(forKey key: String) -> String? {
        return currentPersistence.loadString(forKey: key)
    }

    func saveData(_ value: Data, forKey key: String) {
        currentPersistence.saveData(value, forKey: key)
    }

    func loadData(forKey key: String) -> Data? {
        return currentPersistence.loadData(forKey: key)
    }

    func saveBool(_ value: Bool, forKey key: String) {
        currentPersistence.saveBool(value, forKey: key)
    }

    func loadBool(forKey key: String) -> Bool {
        return currentPersistence.loadBool(forKey: key)
    }

    func remove(forKey key: String) {
        currentPersistence.remove(forKey: key)
    }

    func removeAll(forKeys keys: [String]) {
        currentPersistence.removeAll(forKeys: keys)
    }

    // MARK: - Storage Method Persistence

    func loadSavedPersistenceType() -> PersistenceType {
        // Always use UserDefaults to store the selected persistence type
        let rawValue = UserDefaults.standard.integer(forKey: Keys.persistenceType)
        switch rawValue {
        case 1: return .coreData
        case 2: return .swiftData
        default: return .userDefaults
        }
    }

    func savePersistenceType(_ type: PersistenceType) {
        let rawValue: Int
        switch type {
        case .userDefaults: rawValue = 0
        case .coreData: rawValue = 1
        case .swiftData: rawValue = 2
        }
        UserDefaults.standard.set(rawValue, forKey: Keys.persistenceType)
        UserDefaults.standard.synchronize()
    }

    // MARK: - Data Migration

    func migrateData(from sourceType: PersistenceType, to destinationType: PersistenceType) -> Bool
    {
        guard sourceType != destinationType else { return true }

        print(
            "MIGRATION: Starting migration from \(getCurrentStorageMethodName()) to \(getStorageMethodName(for: destinationType))"
        )

        // Create source and destination persistence instances
        let sourcePersistence = createPersistence(for: sourceType)
        let destinationPersistence = createPersistence(for: destinationType)

        // All keys to migrate
        let allKeys = [
            Keys.shared,
            Keys.sections,
            Keys.userName,
            Keys.userSurname,
            Keys.user,
            Keys.profileImage,
            Keys.selectedTheme,
            Keys.animationsEnabled,
            Keys.taskReminders,
            Keys.soundEffects,
        ]

        var migrationSuccess = true
        var migratedCount = 0

        // Migrate each key
        for key in allKeys {
            do {
                let migrated = try migrateKey(
                    key, from: sourcePersistence, to: destinationPersistence)
                if migrated {
                    migratedCount += 1
                    print("MIGRATION: Migrated key '\(key)'")
                } else {
                    print("MIGRATION: Key '\(key)' not found in source, skipping")
                }
            } catch {
                print("MIGRATION: Failed for key '\(key)' - \(error)")
                migrationSuccess = false
            }
        }

        print("MIGRATION: Migrated \(migratedCount)/\(allKeys.count) keys")

        // Only if migration successful, switch to new type and save preference
        if migrationSuccess {
            self.persistenceType = destinationType
            savePersistenceType(destinationType)

            print(
                "MIGRATION: Successfully switched to \(getStorageMethodName(for: destinationType))"
            )

            // Clean up old data
            sourcePersistence.removeAll(forKeys: allKeys)
            print("MIGRATION: Cleaned up old storage")
        } else {
            print("MIGRATION: Failed, staying with \(getCurrentStorageMethodName())")
        }

        return migrationSuccess
    }

    private func createPersistence(for type: PersistenceType) -> PersistenceProtocol {
        switch type {
        case .userDefaults:
            return UserDefaultsPersistence()
        case .coreData:
            return CoreDataPersistence()
        case .swiftData:
            return SwiftDataPersistence()
        }
    }

    private func migrateKey(
        _ key: String, from source: PersistenceProtocol, to destination: PersistenceProtocol
    ) throws -> Bool {
        // Try different data types in order of likelihood

        // Try Data first (for images and encoded objects like tasks)
        if let data = source.loadData(forKey: key) {
            destination.saveData(data, forKey: key)
            print("Migrated '\(key)' as Data (\(data.count) bytes)")
            return true
        }

        // Try String
        if let string = source.loadString(forKey: key) {
            destination.saveString(string, forKey: key)
            print("Migrated '\(key)' as String: \(string.prefix(50))")
            return true
        }

        // For Bool, only migrate if we're sure the key exists
        // Check known bool keys
        let knownBoolKeys = [Keys.animationsEnabled, Keys.taskReminders, Keys.soundEffects]
        if knownBoolKeys.contains(key) {
            let boolValue = source.loadBool(forKey: key)
            destination.saveBool(boolValue, forKey: key)
            print("✓ Migrated '\(key)' as Bool: \(boolValue)")
            return true
        }

        // Key doesn't exist in source
        return false
    }

    private func getStorageMethodName(for type: PersistenceType) -> String {
        switch type {
        case .userDefaults:
            return "UserDefaults"
        case .coreData:
            return "Core Data"
        case .swiftData:
            return "SwiftData"
        }
    }
}

extension PersistenceManager {
    enum Keys {
        static let shared = "shared"
        static let sections = "abitudine"
        static let dateText = "DateText"
        static let dateTime = "DateTime"
        static let titleText = "TitleText"
        static let tagText = "TagText"
        static let isDone = "isDone"
        static let userName = "UserName"
        static let userSurname = "UserSurname"
        static let user = "User"
        static let profileImage = "ProfileImage"
        static let selectedTheme = "selectedTheme"
        static let animationsEnabled = "animationsEnabled"
        static let taskReminders = "taskReminders"
        static let soundEffects = "soundEffects"
        static let persistenceType = "persistenceType"
    }
}
