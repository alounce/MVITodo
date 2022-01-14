//
//  TodoListMiddleware.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 25.12.2021.
//

import Foundation
import RxSwift

protocol TodoListMiddleware {
    func apply(mutation: TodoListMutation) -> Observable<TodoListMutation>
}

final class TodoListMiddlewareImpl: TodoListMiddleware {
    
    private let flow: MainFlow
    private let bag = DisposeBag()
    
    init(flow: MainFlow) {
        self.flow = flow
    }
    
    func apply(mutation: TodoListMutation) -> Observable<TodoListMutation> {
        if mutation == .addingTodo {
            return addTodo()
        }
        
        if case let .editingTodo(model) = mutation {
            return editTodo(model)
        }
    
        return .just(mutation)
    }
    
    private func addTodo() -> Observable<TodoListMutation> {
        flow.showTodoEditor(for: TodoModel.new())
        return .just(.addingTodo)
    }
    
    private func editTodo(_ todo: TodoModel) -> Observable<TodoListMutation> {
        flow.showTodoEditor(for: todo)
        return .just(.editingTodo(todo))
    }
}
