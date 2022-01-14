//
//  TodoEditorMiddleware.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 28.12.2021.
//

import Foundation
import RxSwift

protocol TodoEditorMiddleware {
    func apply(mutation: TodoEditorMutation) -> Observable<TodoEditorMutation>
}

final class TodoEditorMiddlewareImpl: TodoEditorMiddleware {
    
    private let flow: MainFlow
    
    init(flow: MainFlow) {
        self.flow = flow
    }
    
    func apply(mutation: TodoEditorMutation) -> Observable<TodoEditorMutation> {
        switch mutation {
        case .updated:
            flow.dismiss(completion: nil)
        case .discarded:
            flow.dismiss(completion: nil)
        default:
            break
        }
        return .just(mutation)
    }
}
