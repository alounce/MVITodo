//
//  APIError.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 24.12.2021.
//

import Foundation

enum APIError: Error {
    case invalidLocalResource(String)
    case invalidLocalResourceContent(String)
    case invalidJSON(String)
    case invalidURL
    case insecureConnection
}
