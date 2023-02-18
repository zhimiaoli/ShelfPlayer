//
//  LibraryItem+Media.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 18.02.23.
//

import Foundation

extension LibraryItem {
    /// Specific information about playable items (books, podcasts)
    struct LibraryItemMedia: Codable {
        /// Tags the item is tagged with
        var tags: [String]?
        /// Path where the cover of the item is stored at on the server
        var coverPath: String?
        
        var numTracks: Int?
        var numAudioFiles: Int?
        var numChapters: Int?
        var numMissingParts: Int?
        var numInvalidAudioFiles: Int?
        
        var duration: Double?
        
        var tracks: [AudioTrack]?
        
        var episodes: [PodcastEpisode]?
        
        var metadata: LibraryItemMetadata
        
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
        
        init(description: String?, author: String?) {
            genres = []
            explicit = false
            
            self.description = description
            self.authorName = author
        }
    }
}
