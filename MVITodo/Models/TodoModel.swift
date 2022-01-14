//
//  TodoModel.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 24.12.2021.
//

import Foundation

struct TodoModel: Codable {
    var id: Int
    var title: String
    var details: String
    var priority: Int
    var category: String
    var completed: Bool
    var isNew: Bool { return id < 0 }
}

extension TodoModel {
    private init() {
        self.id = -1
        self.title = ""
        self.details = ""
        self.priority = 1
        self.category = ""
        self.completed = false
    }
    
    static func new() -> TodoModel {
        TodoModel()
    }
}

extension TodoModel {
    mutating func toggle() {
        self.completed = !completed
    }
}

extension TodoModel: Equatable { }
