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
struct LibraryItem: Codable, Identifiable {
    /// Unique identifier for each item
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
    
    // Authors
    let name: String?
    let description: String?
    let numBooks: Int?
    let imagePath: String?
}

extension LibraryItem {
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
    /// Get the title of the itrm
    var title: String {
        media?.metadata.title ?? name ?? "unknown title"
    }
    /// Returns the cover url of the item or nil
    var cover: URL? {
        let user = PersistenceController.shared.getLoggedInUser()!
        
        if isBook {
            return user.serverUrl!.appending(path: "/api/items").appending(path: id).appending(path: "cover").appending(queryItems: [URLQueryItem(name: "token", value: user.token)])
        } else if isAuthor && imagePath != nil {
            return user.serverUrl!.appending(path: "/api/authors").appending(path: id).appending(path: "image").appending(queryItems: [URLQueryItem(name: "token", value: user.token)])
        }
        
        return nil
    }
    
    var isBook: Bool {
        mediaType == "book"
    }
    var isSeries: Bool {
        id.starts(with: "ser_")
    }
    var isAuthor: Bool {
        numBooks != nil
    }
}
