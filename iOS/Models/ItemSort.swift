//
//  ItemSort.swift
//  Books
//
//  Created by Rasmus Krämer on 29.01.23.
//

import Foundation

enum ItemSort: String, CaseIterable {
    case title = "media.metadata.titleIgnorePrefix"
    case size = "size"
    
    // Books:
    case author = "media.metadata.authorName"
    case narrator = "media.metadata.narratorName"
    case seriesName = "media.metadata.seriesName"
    case publishedYear = "media.metadata.publishedYear"
    case addedAt = "addedAt"
    
    // Podcast:
    case podcastAuthor = "media.metadata.author"
}
