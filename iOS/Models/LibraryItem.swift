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

struct LibraryItem: Codable, Identifiable {
    let id: String
    let ino: String?
    let libraryId: String?
    let folderId: String?
    let path: String?
    let mediaType: String?
    
    let addedAt: Double
    let updatedAt: Double?
    
    let isMissing: Bool?
    let isInvalid: Bool?
    
    let size: Double?
    
    let media: LibraryItemMedia?
    
    // Only aviable for Podcats
    let numEpisodes: Int?
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
