//
//  LoginResponse.swift
//  Books
//
//  Created by Rasmus Krämer on 13.11.22.
//

import Foundation

// None of this classes are complete, there are a lot of values missing
struct LoginResponse: Codable {
    var user: ABSUser
    var userDefaultLibraryId: String
    var serverSettings: ServerSettings
}
struct ABSUser: Codable {
    var id: String
    var username: String
    var token: String
    var mediaProgress: [MediaProgress]
    // TODO: seriesHideFromContinueListening
    // TODO: bookmarks
    var permissions: UserPermissions
}
struct ServerSettings: Codable {
    var version: String
}
struct UserPermissions: Codable {
    var download: Bool
    var update: Bool
    var delete: Bool
    var upload: Bool
    var accessAllLibraries: Bool
    var accessAllTags: Bool
    var accessExplicitContent: Bool
}
struct MediaProgress: Codable {
    var id: String
    var libraryItemId: String
    var episodeId: String?
    var duration: Double?
    var progress: Double?
    var currentTime: Double?
    var isFinished: Bool
    var hideFromContinueListening: Bool
    var lastUpdate: Double?
    var startedAt: Double?
    var finishedAt: Double?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        libraryItemId = try container.decode(String.self, forKey: .libraryItemId)
        episodeId = try? container.decode(String.self, forKey: .libraryItemId)
        
        progress = try? container.decode(Double.self, forKey: .progress)
        isFinished = try container.decode(Bool.self, forKey: .isFinished)
        hideFromContinueListening = try container.decode(Bool.self, forKey: .hideFromContinueListening)
        
        lastUpdate = try? container.decode(Double.self, forKey: .lastUpdate)
        startedAt = try? container.decode(Double.self, forKey: .startedAt)
        finishedAt = try? container.decode(Double.self, forKey: .finishedAt)
        
        do {
            duration = try container.decode(Double.self, forKey: .duration)
        } catch {
            if let parsed = try? container.decode(String.self, forKey: .duration) {
                duration = Double(parsed)
            }
        }
        do {
            currentTime = try container.decode(Double.self, forKey: .currentTime)
        } catch {
            if let parsed = try? container.decode(String.self, forKey: .currentTime) {
                currentTime = Double(parsed)
            }
        }
    }
}
