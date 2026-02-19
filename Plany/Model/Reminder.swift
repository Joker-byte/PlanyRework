//
//  Reminder.swift
//  Plany
//
//  Created by Gianluca Dubioso on 10/02/26.
//
import Foundation

struct Reminder : Codable {
    var date: Date?
    var text: String?
    
    enum CodingKeys: String, CodingKey {
        case date
        case text
    }
    
}
