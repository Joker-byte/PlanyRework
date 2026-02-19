//
//  Collections.swift
//  Plany
//
//  Created by Gianluca Dubioso on 04/03/25.
//

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
