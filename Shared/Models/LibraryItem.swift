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
    var id: String
    var ino: String?
    var libraryId: String?
    var folderId: String?
    var path: String?
    var mediaType: String?
    var type: String?
    
    var addedAt: Double?
    var updatedAt: Double?
    
    var isMissing: Bool?
    var isInvalid: Bool?
    
    var size: Double?
    
    var media: LibraryItemMedia?
    var books: [LibraryItem]?
    
    // Local
    var isLocal: Bool?
    var localAuthor: String?
    
    // Podcasts
    var numEpisodes: Int?
    var recentEpisode: PodcastEpisode?
    
    // Authors
    var name: String?
    var description: String?
    var numBooks: Int?
    var imagePath: String?
}

extension LibraryItem {
    struct PodcastEpisode: Codable {
        var id: String?
        var libraryItemId: String?
        var index: Int?
        var season: String?
        var episode: String?
        var title: String?
        var description: String?
        
        var publishedAt: Double?
        var addedAt: Double?
        var updatedAt: Double?
        
        var size: Double?
        var duration: Double?
        
        var audioFile: PodcastAudioFile?
        var audioTrack: AudioTrack?
        
        init(id: String?, libraryItemId: String?, title: String?, description: String?) {
            self.id = id
            self.libraryItemId = libraryItemId
            self.title = title
            self.description = description
        }
        
        // why?
        var seasonData: (String?, String?) {
            var season: String?
            var episode: String?
            
            if self.season != "" {
                season = self.season
            }
            if self.episode != "" {
                episode = self.episode
            }
            
            return (season, episode)
        }
        var length: Double {
            duration ?? audioFile?.duration ?? 0
        }
        
        struct PodcastAudioFile: Codable {
            var duration: Double?
            var codec: String?
            var channelLayout: String?
            
            var metadata: PodcastMetadata?
        }
        struct PodcastMetadata: Codable {
            var size: Double?
        }
    }
    
    struct LibraryItemMedia: Codable {
        var metadata: LibraryItemMetadata
        var tags: [String]?
        var coverPath: String?
        
        // Only aviable for Books
        var numTracks: Int?
        var numAudioFiles: Int?
        var numChapters: Int?
        var numMissingParts: Int?
        var numInvalidAudioFiles: Int?
        
        var duration: Double?
        
        // Only avaiable for Books
        var tracks: [AudioTrack]?
        
        // Only avaiable for Podcasts
        var episodes: [PodcastEpisode]?
        
        init(metdata: LibraryItemMetadata) {
            self.metadata = metdata
        }
    }
    struct LibraryItemMetadata: Codable {
        var title: String?
        var titleIgnorePrefix: String?
        
        var subtitle: String?
        var description: String?
        
        var authorName: String?
        var author: String?
        var narratorName: String?
        var publisher: String?
        var seriesName: String?
        
        var genres: [String]
        var publishedYear: String?
        
        var isbn: String?
        var language: String?
        var explicit: Bool
        
        init(description: String?) {
            genres = []
            explicit = false
            
            self.description = description
        }
    }
}

extension LibraryItem {
    init(id: String, type: String?, name: String?, author: String?, description: String?, isLocal: Bool = false) {
        self.id = id
        self.type = type
        self.mediaType = type
        self.name = name
        self.localAuthor = author
        self.description = description
        
        self.isLocal = isLocal
    }
    
    static func == (lhs: LibraryItem, rhs: LibraryItem) -> Bool {
        if !lhs.isPodcast && !rhs.isPodcast {
            return lhs.identifier == rhs.identifier
        } else {
            return lhs.identifier == rhs.identifier && lhs.media?.episodes?.count == rhs.media?.episodes?.count
        }
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
        localAuthor ?? media?.metadata.authorName ?? media?.metadata.author ?? "unknown author"
    }
    /// Returns the cover url of the item or nil
    var cover: URL? {
        if isLocal ?? false {
            return DownloadHelper.getCover(itemId: id, episodeId: recentEpisode?.id)
        }
        
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
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.ItemUpdated, object: nil)
                }
                
                return true
            } catch {
                let duration = media?.duration ?? recentEpisode?.duration ?? 1
                PersistenceController.shared.updateStatus(itemId: id, episodeId: recentEpisode?.id, currentTime: duration, duration: duration)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.ItemUpdated, object: nil)
                }
                
                return true
            }
        }
        
        return false
    }
}
