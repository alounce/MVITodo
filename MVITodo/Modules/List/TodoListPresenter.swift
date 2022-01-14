//
//  TodoListPresenter.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 25.12.2021.
//

import Foundation
import RxSwift

final class TodoListPresenterImpl: TodoListPresenter {
    private let interactor: TodoListInteractor
    private let middleware: TodoListMiddleware
    private let initialState: TodoListMutation
    
    init(
        interactor: TodoListInteractor,
        middleware: TodoListMiddleware,
        initialState: TodoListMutation
    ) {
        self.interactor = interactor
        self.middleware = middleware
        self.initialState = initialState
    }
    
    func bindIntents(for view: TodoListView) -> Observable<TodoListState> {
        let intentObservable: Observable<TodoListMutation> =
        
        view.actionIntent.flatMap { [interactor] intent -> Observable<TodoListMutation> in
            switch intent {
                
            case .start:
                return interactor.observeTodos()
                
            case .load:
                return interactor.load()
                
            case .addTodo:
                return .just(.addingTodo)
                
            case .editTodo(let model):
                return .just(.editingTodo(model))
                
            case .toggleTodo(let model):
                return interactor.toggle(todo: model)
            
            case .remove:
                return .just(.loading)
            }
        }
        
        return Observable
            .merge(intentObservable)
            .startWith(initialState)
            .flatMap { self.middleware.apply(mutation: $0) }
            .scan(
                .init(),
                accumulator: { (previousState, mutation) -> TodoListState in
                    return mutation.reduce(previousState: previousState)
                }
            )
    }
}
