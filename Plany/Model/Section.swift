//
//  Section.swift
//  Plany
//
//  Created by Gianluca Dubioso on 10/02/26.
//

import Foundation

struct Section: Codable {
  var name: String
  var tasks: [Task]
  
  enum CodingKeys: String, CodingKey {
   case name
   case tasks
  
  }
}
