//
//  Task.swift
//  Plany
//
//  Created by Gianluca Dubioso on 18/12/20.
//
//
import Foundation
import UIKit


struct Task: Codable {
 
  var taskName: String
  var shared: Bool
  var isDone: Bool
  
  enum CodingKeys: String, CodingKey {
    
   case taskName
   case shared
   case isDone
    
  }
    
//  init(from decoder: Decoder) throws {
//          let container = try decoder.container(keyedBy: CodingKeys.self)
//          taskName = try container.decode(String.self, forKey: .taskName)
//          shared = try container.decode(Bool.self, forKey: .shared)
//         isDone = try container.decode(Bool.self, forKey: .isDone)
//  }
}
