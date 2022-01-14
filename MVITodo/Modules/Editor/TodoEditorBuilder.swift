//
//  TodoEditorBuilder.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 28.12.2021.
//

import Foundation
import RxSwift

protocol TodoEditorBuilder {
    func build() -> TodoEditorModule
}

final class TodoEditorBuilderImpl: TodoEditorBuilder {
    
    private let dependencies: Dependencies
    private let flow: MainFlow
    private let todo: TodoModel
    
    init(flow: MainFlow, dependencies: Dependencies, todo: TodoModel) {
        self.flow = flow
        self.dependencies = dependencies
        self.todo = todo
    }
    
    func build() -> TodoEditorModule {
        let interactor = TodoEditorInteractorImpl(flow: flow, dependencies: dependencies, model: todo)
        
        let middleware = TodoEditorMiddlewareImpl(flow: flow)
        let presenter = TodoEditorPresenterImpl(
            interactor: interactor,
            middleware: middleware,
            initialState: .started(todo),
            todo: todo
        )
        let view = TodoEditorController(presenter: presenter)
        return TodoEditorModule(view: view)
    }
}
