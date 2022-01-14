//
//  DependenciesContainer.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 25.12.2021.
//

import Foundation
import UIKit

typealias Dependencies = HasAPIClient & HasDataStore // & plus & something & else

struct DependenciesContainer: Dependencies {
    
    private(set) var apiClient: APIClient
    private(set) var dataStore: DataStore
    
    init(
        api: APIClient = APIClientImpl(),
        store: DataStore = DataStoreImpl()
    ) {
        apiClient = api
        dataStore = store
    }
}
