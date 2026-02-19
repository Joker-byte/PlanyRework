//
//  UserDefaultsPersistence.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import Foundation

final class UserDefaultsPersistence: PersistenceProtocol {
    
    private let userDefaults = UserDefaults.standard
    
    func save<T: Encodable>(_ value: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            userDefaults.set(encoded, forKey: key)
        }
    }
    
    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    func saveString(_ value: String, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    func loadString(forKey key: String) -> String? {
        return userDefaults.string(forKey: key)
    }
    
    func saveData(_ value: Data, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    func loadData(forKey key: String) -> Data? {
        return userDefaults.data(forKey: key)
    }
    
    func saveBool(_ value: Bool, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    func loadBool(forKey key: String) -> Bool {
        return userDefaults.bool(forKey: key)
    }
    
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func removeAll(forKeys keys: [String]) {
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
}
