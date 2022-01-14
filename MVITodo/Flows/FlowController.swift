//
//  FlowController.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 24.12.2021.
//

import Foundation
import RxSwift
import UIKit

protocol HasMainFlow {
    var mainFlow: MainFlow { get }
}

protocol MainFlow {
    func startApplication()
    func showTodoList()
    func showTodoEditor(for model: TodoModel)
    
    func dismiss(completion: (() -> Void)?)
}

class MainFlowController: MainFlow {
    
    private var navigationController: UINavigationController
    private var dependencies: Dependencies
    
    init(navigationController: UINavigationController, dependencies: Dependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func startApplication() {
        showTodoList()
    }
    
    func showTodoList() {
        guard let list =
                TodoListBuilderImpl(
                    flow: self,
                    dependencies: dependencies
                )
                .build()
                .view as? TodoListController else { return }
        
        navigationController.viewControllers = [list]
    }
    
    func showTodoEditor(for todo: TodoModel) {
        guard let editor =
        TodoEditorBuilderImpl(flow: self, dependencies: self.dependencies, todo: todo)
            .build()
                .view as? TodoEditorController else { return }
        let nav = UINavigationController(rootViewController: editor)
        self.navigationController.present(nav, animated: true, completion: nil)
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        navigationController
            .topViewController?
            .dismiss(animated: true, completion: completion)
    }
    
}
