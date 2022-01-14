//
//  DataStore.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 12.01.2022.
//

import Foundation
import RxSwift

protocol HasDataStore {
    var dataStore: DataStore { get }
}

protocol DataStore {
    var todos: PublishSubject<[TodoModel]> { get }
    func store(todos: [TodoModel])
    func store(todo: TodoModel)
}

class DataStoreImpl: DataStore {
    private var todosCache = [TodoModel]()
    var todos = PublishSubject<[TodoModel]>()
    
    func store(todos items: [TodoModel]) {
        todosCache = items
        todos.onNext(items)
    }
    
    func store(todo: TodoModel) {
        // -------------------------------------------------------
        // this is the hack that must be removed with true saving
        var todo = todo
        if todo.id < 0 {
            todo.id = makeNextId()
        }
        // -------------------------------------------------------
        
        if let index = todosCache.firstIndex(where: { $0.id == todo.id }) {
            // update existing
            todosCache[index] = todo
        } else {
            // or add new
            todosCache.append(todo)
        }
        todos.onNext(todosCache)
    }
    
    private func makeNextId() -> Int {
        (todosCache.map { $0.id }.max() ?? -1) + 1
    }
}
