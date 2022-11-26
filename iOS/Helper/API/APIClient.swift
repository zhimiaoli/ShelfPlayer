//
//  ApiClient.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import Foundation
import Combine

class APIClient {
    static private(set) var authorizedShared = getAuthorizedClient()
    
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
        var url = baseUrl.appending(path: resource.path)
        if let query = resource.query {
            url = url.appending(queryItems: query)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = resource.method

        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = resource.body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            } catch {
                print("Unable to encode body \(error)")
                throw APIError.failedEncode
            }
        }

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
