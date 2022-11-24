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
        public func post(username: String, password: String) -> APIRequest<AuthorizeResponse> {
            APIRequest(method: "POST", path: "login", body: [
                "username": username,
                "password": password,
            ])
        }
    }
}

// MARK: - /api/authorize
extension APIResources {
    public static var authorize: AuthorizeResource {
        AuthorizeResource()
    }
    
    public struct AuthorizeResource {
        public var post: APIRequest<AuthorizeResponse> {
            APIRequest(method: "POST", path: "api/authorize")
        }
    }
}

// MARK: - /api/libraries/{id}
extension APIResources {
    public static func libraries(id: String) -> LibrariesResource {
        LibrariesResource(id: id)
    }
    
    public struct LibrariesResource {
        public var id: String
        
        public var personalized: APIRequest<[PersonalizedLibraryRow]> {
            APIRequest(method: "GET", path: "api/libraries/\(id)/personalized")
        }
    }
}
