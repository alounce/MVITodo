//
//  TodoListInteractor.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 25.12.2021.
//

import Foundation
import RxSwift

protocol TodoListInteractor: Interactor {
    func observeTodos() -> Observable<TodoListMutation>
    func load() -> Observable<TodoListMutation>
    func toggle(todo: TodoModel) -> Observable<TodoListMutation>
}

final class TodoListInteractorImpl: TodoListInteractor {
    
    typealias Dependencies = HasAPIClient & HasDataStore
    private let dependencies: Dependencies
    private let flow: MainFlow
    private var bag = DisposeBag()
    
    private var todosSubject: BehaviorSubject<[TodoModel]> = .init(value: [])
    
    init(flow: MainFlow, dependencies: Dependencies) {
        self.flow = flow
        self.dependencies = dependencies
        dependencies.dataStore.todos.subscribe { [weak self] todos in
            self?.todosSubject.onNext(todos)
        }
        .disposed(by: bag)
    }
    
    func observeTodos() -> Observable<TodoListMutation> {
        todosSubject.asObservable().map { .loaded($0) }
    }
    
    func load() -> Observable<TodoListMutation> {
        
        return dependencies
            .apiClient
            .loadTodos()
            .asObservable()
            .do(onNext: { [weak self] items in
                guard let self = self else { return }
                self.dependencies.dataStore.store(todos: items)
            })
            .map { data in .loaded(data) }
            .catchAndReturn(.failed)
            .startWith(.loading)
    }
    
    func toggle(todo: TodoModel) -> Observable<TodoListMutation> {
        
        return dependencies
            .apiClient
            .toggle(todo: todo)
            .asObservable()
            .do(onNext: { [weak self] updated in
                guard let self = self else { return }
                self.dependencies.dataStore.store(todo: updated)
            })
            .map { _ in .toggledTodo(todo) }
            .catchAndReturn(.failed)
            .startWith(.togglingTodo(todo))
    }
}
