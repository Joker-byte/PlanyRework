//
//  SwiftDataPersistence.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import Foundation

final class SwiftDataPersistence: PersistenceProtocol {
    
    func save<T: Encodable>(_ value: T, forKey key: String) {
    }
    
    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        return nil
    }
    
    func saveString(_ value: String, forKey key: String) {
    }
    
    func loadString(forKey key: String) -> String? {
        return nil
    }
    
    func saveData(_ value: Data, forKey key: String) {
    }
    
    func loadData(forKey key: String) -> Data? {
        return nil
    }
    
    func saveBool(_ value: Bool, forKey key: String) {
    }
    
    func loadBool(forKey key: String) -> Bool {
        return false
    }
    
    func remove(forKey key: String) {
    }
    
    func removeAll(forKeys keys: [String]) {
    }
}
