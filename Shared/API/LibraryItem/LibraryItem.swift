//
//  LibraryItem.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import Foundation

/// Item retrived from the audiobookshelf server or created of downloaded data
struct LibraryItem: Codable, Equatable {
    /// Unique identifier for books and pocasts (not episodes)
    var id: String
    /// Library the item is stored in
    var libraryId: String?
    /// Path the item is stored at on the server
    var path: String?
    /// Value indicating the type of the item. Only present on books and podcasts
    var mediaType: String?
    /// Value indicating the type of the item. Only present on series
    var type: String?
    
    /// Date at which the item was added to the library
    var addedAt: Double?
    /// Date at which the item was last updated
    var updatedAt: Double?
    
    /// Size of all media files stored on the server
    var size: Double?
    
    /// Books contained by the series
    var books: [LibraryItem]?
    
    /// Numebr of episodes the podcast has
    var numEpisodes: Int?
    /// Latest episode of the podcast. Can also be used to transform the type of the item from podcast to episode
    var recentEpisode: PodcastEpisode?
    
    /// Value indicating whether the item is created of local files of retrived from the server
    var isLocal: Bool?
    
    /// Name of the author
    var name: String?
    /// Description of the author's life
    var description: String?
    /// Number of book avaiable on the server written by the author
    var numBooks: Int?
    /// Path of a image of the author stored on the server
    var imagePath: String?
    
    var media: LibraryItemMedia?
}

extension LibraryItem {
    init(id: String, type: String?, name: String?, author: String?, description: String?, isLocal: Bool = false) {
        self.id = id
        self.type = type
        self.mediaType = type
        self.name = name
        self.description = description
        
        self.media = LibraryItemMedia(metdata: LibraryItemMetadata(description: description, author: author))
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
