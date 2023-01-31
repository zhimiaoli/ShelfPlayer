//
//  APIRequest.swift
//  Books
//
//  Created by Rasmus Krämer on 13.11.22.
//

import Foundation

public struct APIRequest<Response> {
    var method: String
    var path: String
    var body: Any?
    var query: [URLQueryItem]?
}

public struct APIRequestEmpty {
    var method: String
    var path: String
    var body: Any?
    var query: [URLQueryItem]?
}
