//
//  ApiClient.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import Foundation
import Combine

class APIClient {
    static private(set) var authorizedShared: APIClient = getAuthorizedClient()
    
    private static func getAuthorizedClient() -> APIClient {
        let user = PersistenceController.shared.getLoggedInUser()
        return try! APIClient(serverUrl: user?.serverUrl?.absoluteString ?? "https://example.com", token: user?.token)
    }
    public static func updateAuthorizedClient() {
        authorizedShared = getAuthorizedClient()
    }
    
    private var baseUrl: URL
    private var token: String?
    
    init(serverUrl: String, token: String?) throws {
        guard let url = URL(string: serverUrl) else {
            throw APIError.invalidURL
        }
        
        self.baseUrl = url
        self.token = token
    }
    
    func request<T: Decodable>(_ resource: APIRequest<T>) async throws -> T {
        let data = try await _request(path: resource.path, method: resource.method, query: resource.query, body: resource.body)
        // print(String.init(data: data, encoding: .utf8))
        return try JSONDecoder().decode(T.self, from: data)
    }
    func request(_ resource: APIRequestEmpty) async throws {
        let _ = try await _request(path: resource.path, method: resource.method, query: resource.query, body: resource.body)
    }
    
    private func _request(path: String, method: String, query: [URLQueryItem]?, body: Any?) async throws -> Data {
        var url = baseUrl.appending(path: path)
        if let query = query {
            url = url.appending(queryItems: query)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                // print(String(data: request.httpBody!, encoding: .ascii))
                
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            } catch {
                print("Unable to encode body \(error)")
                throw APIError.failedEncode
            }
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}
