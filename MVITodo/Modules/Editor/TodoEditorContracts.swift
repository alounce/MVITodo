//
//  TodoEditorContracts.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 28.12.2021.
//

import Foundation
import RxSwift

// MARK: - Components

struct TodoEditorModule {
    let view: TodoEditorView
}

// MARK: - Intents

enum TodoEditorViewIntent {
    case start
    case save(TodoModel)
    case discard
}

// MARK: - State

struct TodoEditorState: Equatable {
    var todo: TodoModel
    
    var isLoading: Bool = false
    var isSaving: Bool = false
    var errorMessage: String?
}

enum TodoEditorMutation: Equatable {
    
    case started(TodoModel)
    case discarded
    case updating
    case updated(TodoModel)
    case failed
    
    func reduce(previousState: TodoEditorState) -> TodoEditorState {
        var state = previousState
        state.errorMessage = nil
        
        if case .started = self {
            state.isLoading = true
        } else {
            state.isLoading = false
        }
        state.isSaving = self == .updating
        
        switch self {
        case .started(let model):
            state.todo = model
        case .failed:
            state.errorMessage = "Unable to save data"
        case .updated(let updated):
            state.todo = updated
        default:
            break
        }
        return state
    }
}
