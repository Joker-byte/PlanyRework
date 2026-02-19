//
//  StorageService.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import Foundation

final class StorageService {
    
    static let shared = StorageService()
    
    private let persistence = PersistenceManager.shared
    
    private init() {}
    
    func save<T: Encodable>(_ value: T, forKey key: String) {
        persistence.save(value, forKey: key)
    }
    
    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        return persistence.load(type, forKey: key)
    }
    
    func saveString(_ value: String, forKey key: String) {
        persistence.saveString(value, forKey: key)
    }
    
    func loadString(forKey key: String) -> String? {
        return persistence.loadString(forKey: key)
    }
    
    func saveData(_ value: Data, forKey key: String) {
        persistence.saveData(value, forKey: key)
    }
    
    func loadData(forKey key: String) -> Data? {
        return persistence.loadData(forKey: key)
    }
    
    func saveBool(_ value: Bool, forKey key: String) {
        persistence.saveBool(value, forKey: key)
    }
    
    func loadBool(forKey key: String) -> Bool {
        return persistence.loadBool(forKey: key)
    }
    
    func remove(forKey key: String) {
        persistence.remove(forKey: key)
    }
    
    func removeAll(forKeys keys: [String]) {
        persistence.removeAll(forKeys: keys)
    }
}

extension StorageService {
    typealias Keys = PersistenceManager.Keys
}
