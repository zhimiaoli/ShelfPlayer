//
//  APIError.swift
//  Books
//
//  Created by Rasmus Krämer on 13.11.22.
//

import Foundation

enum APIError: Error {
    case failedRequest
    case invalidResponse
    case unreachable
    case failedEncode
    case invalidURL
}
