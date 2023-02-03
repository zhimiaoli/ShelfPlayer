//
//  GlobalViewModel.swift
//  Books
//
//  Created by Rasmus Krämer on 27.01.23.
//

import Foundation
import SwiftUI

/// View model containing essential data which should be avOaiable everywhere
class GlobalViewModel: ObservableObject {
    @Published var activeLibraryId: String = ""
    @Published var activeLibraryType: String?
    
    @Published var token: String = ""
    @Published var loggedIn: Bool = false
    
    @Published var settingsSheetPresented: Bool = false
    @Published var onlineStatus: OnlineStatus = .unknown
    
    @Published private(set) var currentlyPlaying: LibraryItem?
    @Published private(set) var currentPlaySession: PlayResponse?
    
    @Published var showNowPlayingBar: Bool = false
    @Published var nowPlayingSheetPresented: Bool = false
    
    // MARK: - User related functions
    /// Delete all data related to the user and present the login screen
    public func logout() {
        try! PersistenceController.shared.deleteLoggedInUser()
        try! PersistenceController.shared.deleteAllCachedSessions()
        
        APIClient.updateAuthorizedClient()
        
        onlineStatus = .offline
        loggedIn = false
        
        token = ""
        activeLibraryId = ""
    }
    /// Verify the stored token and update the local media progress
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
    
    // MARK: - Playback related functions
    /// Start playback of a library item and display the now paying view
    /// - Parameters:
    ///   - item: Item to play
    public func playItem(item: LibraryItem) {
        if currentlyPlaying?.identifier == item.identifier {
            nowPlayingSheetPresented = true
            return
        }
        
        closePlayer()
        
        Task.detached {
            do {
                let playResponse = try await APIClient.authorizedShared.request(APIResources.items(id: item.id).play(episodeId: item.recentEpisode?.id))
                PlayerHelper.audioPlayer = AudioPlayer(sessionId: playResponse.id, itemId: item.id, episodeId: item.recentEpisode?.id, startTime: playResponse.startTime, playMethod: PlayMethod(rawValue: playResponse.playMethod) ?? .directPlay, audioTracks: playResponse.audioTracks)
                
                DispatchQueue.main.async {
                    withAnimation {
                        self.currentPlaySession = playResponse
                        self.currentlyPlaying = item
                        
                        self.showNowPlayingBar = true
                        self.nowPlayingSheetPresented = true
                    }
                }
            } catch {
                print(error, "Failed to start player")
            }
        }
    }
    public func playLocalItem(item: LibraryItem, tracks: [AudioTrack]) {
        if currentlyPlaying?.identifier == item.identifier {
            nowPlayingSheetPresented = true
            return
        }
        
        closePlayer()
        
        Task.detached {
            // TODO: start time
            let entity = PersistenceController.shared.getEnitityByLibraryItem(item: item, required: true)
            PlayerHelper.audioPlayer = AudioPlayer(sessionId: nil, itemId: item.id, episodeId: item.recentEpisode?.id, startTime: entity?.currentTime ?? 0, playMethod: .local, audioTracks: tracks)
            
            DispatchQueue.main.async {
                withAnimation {
                    self.currentlyPlaying = item
                    
                    self.showNowPlayingBar = true
                    self.nowPlayingSheetPresented = true
                }
            }
        }
    }
    public func closePlayer() {
        self.nowPlayingSheetPresented = false
        self.showNowPlayingBar = false
        
        PlayerHelper.audioPlayer?.destroy()
        PlayerHelper.audioPlayer = nil
    }
    
    // MARK: - Library related functons
    /// Select a active library and update the lastActiveLibraryId
    public func selectLibrary(libraryId: String, type: String? = nil) {
        activeLibraryId = libraryId
        activeLibraryType = type
        
        let user = PersistenceController.shared.getLoggedInUser()
        user!.lastActiveLibraryId = libraryId
        
        try? PersistenceController.shared.container.viewContext.save()
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
