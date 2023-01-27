//
//  GlobalViewModel.swift
//  Books
//
//  Created by Rasmus Krämer on 27.01.23.
//

import Foundation

/// View model containing essential data which should be avaiable everywhere
class GlobalViewModel: ObservableObject {
    @Published var activeLibraryId: String = ""
    @Published var token: String = ""
    @Published var loggedIn: Bool = false
    
    @Published var onlineStatus: OnlineStatus = .unknown
    
    // MARK: - User related functions
    public func logout() {
        try! PersistenceController.shared.deleteLoggedInUser()
        try! PersistenceController.shared.deleteAllCachedSessions()
        
        APIClient.updateAuthorizedClient()
        
        onlineStatus = .offline
        loggedIn = false
        
        token = ""
        activeLibraryId = ""
    }
    @Sendable public func authorize() async {
        do {
            try await pingServer()
        } catch {
            DispatchQueue.main.async {
                self.onlineStatus = .offline
            }
            return
        }
        
        do {
            try await authorizeSession()
        } catch {
            logout()
        }
        
        DispatchQueue.main.async {
            if let user = PersistenceController.shared.getLoggedInUser() {
                self.token = user.token!
                self.activeLibraryId = user.lastActiveLibraryId!
                
                self.loggedIn = true
                self.onlineStatus = .online
            }
        }
    }
    
    // MARK: - Private functions
    /// Try to ping the server of the logged in user
    private func pingServer() async throws {
        if try await APIClient.authorizedShared.request(APIResources.ping.get).success != true {
            throw APIError.invalidResponse
        }
    }
    /// Validate the token of the logged in user and update local media progress
    private func authorizeSession() async throws {
        let authorizeResponse = try await APIClient.authorizedShared.request(APIResources.authorize.post)
        
        DispatchQueue.global(qos: .background).async {
            PersistenceController.shared.updateMediaProgressDatabase(authorizeResponse.user.mediaProgress)
        }
    }
    
    enum OnlineStatus {
        case unknown
        case offline
        case online
    }
}
