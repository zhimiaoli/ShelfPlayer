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
    var body: Encodable?
    var query: [URLQueryItem]?
}
