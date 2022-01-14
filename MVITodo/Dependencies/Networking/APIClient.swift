//
//  APIClient.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 24.12.2021.
//

import Foundation
import RxSwift

protocol HasAPIClient {
    var apiClient: APIClient { get }
}

protocol APIClient {
    func loadTodos() -> Single<[TodoModel]>
    func save(todo: TodoModel) -> Single<TodoModel>
    func toggle(todo: TodoModel) -> Single<TodoModel>
}

class APIClientImpl: APIClient {
    
    func loadTodos() -> Single<[TodoModel]> {
        Single<[TodoModel]>.create { single in
            // Todo: implement real network operation here...
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                let resourceName = "Todos.json"
                
                guard let url = Bundle.main.url(forResource: resourceName, withExtension: "") else {
                    single(.failure(APIError.invalidLocalResource(resourceName)))
                    return
                }
                
                guard let raw = try? Data(contentsOf: url) else {
                    single(.failure(APIError.invalidLocalResourceContent(resourceName)))
                    return
                }
                
                var todos = [TodoModel]()
                do {
                    todos = try JSONDecoder().decode([TodoModel].self, from: raw)
                } catch {
                    single(.failure(APIError.invalidJSON(resourceName)))
                }
                
                single(.success(todos))
            }
            return Disposables.create()
        }
    }
    
    func save(todo: TodoModel) -> Single<TodoModel> {
        
        Single<TodoModel>.create { single in
            // Todo: implement real network operation here...
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                single(.success(todo))
            }
            return Disposables.create()
        }
    }
    
    func toggle(todo: TodoModel) -> Single<TodoModel> {
        Single<TodoModel>.create { single in
            var todo = todo
            todo.toggle()
            // Todo: implement real network operation here...
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                single(.success(todo))
            }
            return Disposables.create()
        }
    }
}
