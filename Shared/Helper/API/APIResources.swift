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

// MARK: - /api/libraries/
extension APIResources {
    public static var libraries: LibrariesResource {
        LibrariesResource()
    }
    
    
    public struct LibrariesResource {
        public func get() -> APIRequest<LibrariesResponse<Library>> {
            APIRequest(method: "GET", path: "api/libraries")
        }
    }
}

// MARK: - /api/libraries/{id}
extension APIResources {
    public static func libraries(id: String) -> LibraryResource {
        LibraryResource(id: id)
    }
    
    public struct LibraryResource {
        public var id: String
        
        public var personalized: APIRequest<[PersonalizedLibraryRow]> {
            APIRequest(method: "GET", path: "api/libraries/\(id)/personalized")
        }
        
        public func items(sort: ItemSort = .title, minified: Bool = true) -> APIRequest<FilterResponse<LibraryItem>> {
            return APIRequest(method: "GET", path: "api/libraries/\(id)/items", query: [
                URLQueryItem(name: "sort", value: sort.rawValue),
                URLQueryItem(name: "minified", value: minified ? "1" : "0")
            ])
        }
        public func items(filter: String, limit: Int = 100, page: Int = 0, minified: Bool = true) -> APIRequest<FilterResponse<LibraryItem>> {
            return APIRequest(method: "GET", path: "api/libraries/\(id)/items", query: [
                URLQueryItem(name: "filter", value: filter),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "minified", value: minified ? "1" : "0")
            ])
        }
        
        public func series(sort: SeriesSort, descending: Bool = false, minified: Bool = true) -> APIRequest<FilterResponse<LibraryItem>> {
            return APIRequest(method: "GET", path: "api/libraries/\(id)/series", query: [
                URLQueryItem(name: "sort", value: sort.rawValue),
                URLQueryItem(name: "desc", value: descending ? "1" : "0"),
                URLQueryItem(name: "minified", value: minified ? "1" : "0")
            ])
        }
        public func search(query: String, limit: Int = 15) -> APIRequest<SearchResponse<LibraryItem>> {
            return APIRequest(method: "GET", path: "api/libraries/\(id)/search", query: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "limit", value: String(limit)),
            ])
        }
    }
}

// MARK: - /api/series
extension APIResources {
    public static var series: SeriesResource {
        SeriesResource()
    }
    
    public struct SeriesResource {
        public func seriesByName(search: String) -> APIRequest<FilterResponse<SearchSeries>> {
            APIRequest(method: "GET", path: "api/series/search", query: [URLQueryItem(name: "q", value: search)])
        }
        
        public func byId(id: String) -> APIRequest<LibraryItem> {
            APIRequest(method: "GET", path: "api/series/\(id)")
        }
    }
}

// MARK: - /api/me/progress/{id}
extension APIResources {
    public static func progress(id: String) -> ProgressResource {
        ProgressResource(id: id)
    }
    
    public struct ProgressResource {
        public var id: String
        
        public func finished(finished: Bool) -> APIRequestEmpty {
            APIRequestEmpty(method: "PATCH", path: "api/me/progress/\(id)", body: [
                "isFinished": finished,
            ])
        }
    }
}

// MARK: - /api/items/{id}
extension APIResources {
    public static func items(id: String) -> ItemResource {
        ItemResource(id: id)
    }
    
    public struct ItemResource {
        public var id: String
        
        public var get: APIRequest<LibraryItem> {
            return APIRequest(method: "GET", path: "api/items/\(id)", query: [
                URLQueryItem(name: "expanded", value: "1"),
            ])
        }
        
        public func play(episodeId: String? = nil) -> APIRequest<PlayResponse> {
            return APIRequest(method: "POST", path: "api/items/\(id)/play\(episodeId != nil ? "/\(episodeId!)" : "")", body: [
                "mediaPlayer": "AVPlayer",
                "deviceInfo": [
                    "manufacturer": "Apple",
                    "model": "iPhone",
                    "clientVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "beta",
                ],
                "supportedMimeTypes": ["audio/flac", "audio/mpeg", "audio/mp4", "audio/aac", "audio/x-aiff", "audio/webm"],
            ])
        }
    }
}

// MARK: - /api/session/{id}
extension APIResources {
    public static func session(id: String) -> SessionResource {
        SessionResource(id: id)
    }
    
    public struct SessionResource {
        public var id: String
        
        public func sync(timeListened: Double, duration: Double, currentTime: Double) -> APIRequestEmpty {
            APIRequestEmpty(method: "POST", path: "api/session/\(id)/sync", body: [
                "timeListened": timeListened,
                "duration": duration,
                "currentTime": currentTime,
            ])
        }
    }
}
