//
//  TodoEditorPresenter.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 28.12.2021.
//

import Foundation
import RxSwift

protocol TodoEditorPresenter: AnyObject, Presenter {
    var todo: TodoModel { get }
    func bindIntents(for view: TodoEditorView) -> Observable<TodoEditorState>
}

final class TodoEditorPresenterImpl: TodoEditorPresenter {
    
    private let interactor: TodoEditorInteractor
    private let middleware: TodoEditorMiddleware
    private let initialState: TodoEditorMutation
    
    var todo: TodoModel
    
    init(
        interactor: TodoEditorInteractor,
        middleware: TodoEditorMiddleware,
        initialState: TodoEditorMutation,
        todo: TodoModel
    ) {
        self.interactor = interactor
        self.middleware = middleware
        
        self.todo = todo
        self.initialState = initialState
    }
    
    func bindIntents(for view: TodoEditorView) -> Observable<TodoEditorState> {
        
        let intentObservable: Observable<TodoEditorMutation> =
        view.actionIntent.flatMap { [interactor] intent -> Observable<TodoEditorMutation> in
            switch intent {
            case .start:
                return interactor.load()
                
            case .save(let todo):
                return interactor.save(todo: todo)
                
            case TodoEditorViewIntent.discard:
                // pass this to middleware
                return .just(.discarded)
            }
        }
        
        return Observable
            .merge(intentObservable)
            .startWith(.started(todo))
            .flatMap { self.middleware.apply(mutation: $0) }
            .scan(
                .init(todo: todo),
                accumulator: { (previousState, mutation) -> TodoEditorState in
                    return mutation.reduce(previousState: previousState)
                }
            )
        }
}
