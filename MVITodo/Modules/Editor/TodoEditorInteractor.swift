//
//  TodoEditorInteractor.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 28.12.2021.
//

import Foundation
import RxSwift

protocol TodoEditorInteractor: Interactor {
    func load() -> Observable<TodoEditorMutation>
    func save(todo: TodoModel) -> Observable<TodoEditorMutation>
}

enum TodoEditorError: Error {
    case discarded
}

final class TodoEditorInteractorImpl: TodoEditorInteractor {
    
    typealias Dependencies = HasAPIClient & HasDataStore
    private let dependencies: Dependencies
    private let flow: MainFlow
    private let model: TodoModel
    
    init(flow: MainFlow, dependencies: Dependencies, model: TodoModel) {
        self.flow = flow
        self.dependencies = dependencies
        self.model = model
    }
    
    func load() -> Observable<TodoEditorMutation> {
        return .just(.started(model))
    }
    
    func save(todo: TodoModel) -> Observable<TodoEditorMutation> {
        dependencies
            .apiClient
            .save(todo: todo)
            .asObservable()
            .do(onNext: { [weak self] updated in
                guard let self = self else { return }
                self.dependencies.dataStore.store(todo: updated)
            })
            .map { item in
                .updated(item)
            }
            .catchAndReturn(.failed)
            .startWith(.updating)
    }
}
