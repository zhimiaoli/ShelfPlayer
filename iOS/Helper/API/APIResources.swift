//
//  APIRequest.swift
//  Books
//
//  Created by Rasmus Krämer on 13.11.22.
//

import Foundation

enum APIResources {}

// MARK: - /ping
extension APIResources {
    public static var ping: PingResource {
        PingResource()
    }
    
    public struct PingResource {
        public var get: APIRequest<PingResponse> {
            APIRequest(method: "GET", path: "ping")
        }
    }
}

// MARK: - /login
extension APIResources {
    public static var login: LoginResource {
        LoginResource()
    }
    
    public struct LoginResource {
        public func post(username: String, password: String) -> APIRequest<LoginResponse> {
            APIRequest(method: "POST", path: "login", body: [
                "username": username,
                "password": password,
            ])
        }
    }
}
