//
//  TodoListBase.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 24.12.2021.
//

import Foundation
import RxSwift

// MARK: - Components

struct TodoListModule {
    let view: TodoListView
}

protocol TodoListView: View {
    var actionIntent: Observable<TodoListIntent> { get }
    func render(for state: TodoListState)
}

protocol TodoListPresenter: AnyObject, Presenter {
    func bindIntents(for view: TodoListView) -> Observable<TodoListState>
}

// MARK: - Intents

enum TodoListIntent {
    case start
    case load
    case addTodo
    case editTodo(TodoModel)
    case toggleTodo(TodoModel)
    case remove(TodoModel)
}

// MARK: - State

struct TodoListState: Equatable {
    
    var errorMessage: String?
    var hasError: Bool { errorMessage != nil }
    var isLoading: Bool = false
    
    var items: [TodoModel] = []
    var blockedItems = Set<Int>()
}

enum TodoListMutation: Equatable {
    case loading
    case loaded([TodoModel])
    case failed
    case addingTodo
    case editingTodo(TodoModel)
    case updatedTodo(TodoModel)
    case togglingTodo(TodoModel)
    case toggledTodo(TodoModel)
    
    func reduce(previousState: TodoListState) -> TodoListState {
        var state = previousState
        state.errorMessage = nil
        state.isLoading = self == .loading
        
        switch self {
        case .togglingTodo(let todo):
            state.blockedItems.insert(todo.id)
        case .toggledTodo(let todo):
            state.blockedItems.remove(todo.id)
        case .failed:
            state.errorMessage = "Unable to load data"
        case .loaded(let items):
            state.items = items
        default:
            break
        }
        return state
    }
}
