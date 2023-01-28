//
//  LibraryItem.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import Foundation

/*
 This is just "Library Item Minified" not "Library Item".
 Also the "media" field works for both books and podcasts
 */

/// Item retrived from a ABS server
struct LibraryItem: Codable, Equatable {
    let id: String
    let ino: String?
    let libraryId: String?
    let folderId: String?
    let path: String?
    let mediaType: String?
    let type: String?
    
    let addedAt: Double
    let updatedAt: Double?
    
    let isMissing: Bool?
    let isInvalid: Bool?
    
    let size: Double?
    
    let media: LibraryItemMedia?
    let books: [LibraryItem]?
    
    // Podcasts
    let numEpisodes: Int?
    let recentEpisode: PodcastEpisode?
    
    // Authors
    let name: String?
    let description: String?
    let numBooks: Int?
    let imagePath: String?
    
    static func == (lhs: LibraryItem, rhs: LibraryItem) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

extension LibraryItem {
    struct PodcastEpisode: Codable {
        let id: String?
        let libraryItemId: String?
        let index: Int?
        let season: String?
        let episode: String?
        let title: String?
        let description: String?
        
        let publishedAt: Double?
        let addedAt: Double?
        let updatedAt: Double?
    }
    
    struct LibraryItemMedia: Codable {
        let metadata: LibraryItemMetadata
        let tags: [String]?
        let coverPath: String?
        
        // Only aviable for Books
        let numTracks: Int?
        let numAudioFiles: Int?
        let numChapters: Int?
        let numMissingParts: Int?
        let numInvalidAudioFiles: Int?
        
        let duration: Double?
    }
    
    struct LibraryItemMetadata: Codable {
        let title: String?
        let titleIgnorePrefix: String?
        
        let subtitle: String?
        let description: String?
        
        let authorName: String?
        let narratorName: String?
        let publisher: String?
        let seriesName: String?
        
        let genres: [String]
        let publishedYear: String?
        
        let isbn: String?
        let language: String?
        let explicit: Bool
    }
}

extension LibraryItem {
    /// Get the unique identifier of the item
    var identifier: String {
        recentEpisode?.id ?? id
    }
    
    /// Get the title of the item
    var title: String {
        recentEpisode?.title ?? media?.metadata.title ?? name ?? "unknown title"
    }
    var author: String {
        media?.metadata.authorName ?? "unknown author"
    }
    /// Returns the cover url of the item or nil
    var cover: URL? {
        let user = PersistenceController.shared.getLoggedInUser()!
        
        if isBook || isPodcast {
            return user.serverUrl!.appending(path: "/api/items").appending(path: id).appending(path: "cover").appending(queryItems: [URLQueryItem(name: "token", value: user.token)])
        } else if isAuthor && imagePath != nil {
            return user.serverUrl!.appending(path: "/api/authors").appending(path: id).appending(path: "image").appending(queryItems: [URLQueryItem(name: "token", value: user.token)])
        }
        
        return nil
    }
    
    var isBook: Bool {
        mediaType == "book"
    }
    var isPodcast: Bool {
        mediaType == "podcast"
    }
    var isSeries: Bool {
        id.starts(with: "ser_")
    }
    var isAuthor: Bool {
        numBooks != nil
    }
    var hasEpisode: Bool {
        recentEpisode != nil
    }
}


extension LibraryItem {
    func toggleFinishedStatus() async -> Bool {
        if isBook || (isPodcast && hasEpisode) {
            do {
                let progress = PersistenceController.shared.getProgressByLibraryItem(item: self)
                var progressId: String = id
                
                if hasEpisode {
                    progressId.append("/")
                    progressId.append(recentEpisode?.id ?? "")
                }
                
                try await APIClient.authorizedShared.request(APIResources.progress(id: progressId).finished(finished: progress != 1))
                PersistenceController.shared.updateStatusWithoutUpdate(item: self, progress: progress == 1 ? 0 : 1)
                
                return true
            } catch {}
        }
        
        return false
    }
}
