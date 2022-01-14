//
//  TodoListBuilder.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 25.12.2021.
//

import Foundation
import RxSwift

protocol TodoListBuilder {
    func build() -> TodoListModule
}

final class TodoListBuilderImpl: TodoListBuilder {
    
    private let dependencies: Dependencies
    private let flow: MainFlow
    
    init(flow: MainFlow, dependencies: Dependencies) {
        self.flow = flow
        self.dependencies = dependencies
    }
    
    func build() -> TodoListModule {
        let interactor = TodoListInteractorImpl(flow: flow, dependencies: dependencies)
        let middleware = TodoListMiddlewareImpl(flow: flow)
        let presenter = TodoListPresenterImpl(
            interactor: interactor,
            middleware: middleware,
            initialState: .loading
        )
        let view = TodoListController(presenter: presenter)
        return TodoListModule(view: view)
    }
}
