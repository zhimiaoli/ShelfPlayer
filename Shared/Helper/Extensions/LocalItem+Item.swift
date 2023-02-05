//
//  LocalItem+Item.swift
//  Books
//
//  Created by Rasmus Krämer on 05.02.23.
//

import Foundation

extension LocalItem {
    func convertToItem() -> LibraryItem {
        var item = LibraryItem(
            id: itemId!,
            type: episodeId == nil ? "book" : "podcast",
            name: title,
            author: author,
            description: descriptionText,
            isLocal: true
        )
        
        if episodeId == nil {
            let media = LibraryItem.LibraryItemMedia(metdata: LibraryItem.LibraryItemMetadata(description: descriptionText))
            item.media = media
        } else {
            let epeisode = LibraryItem.PodcastEpisode(id: episodeId, libraryItemId: itemId, title: episodeTitle, description: episodeDescription)
            item.recentEpisode = epeisode
            item.recentEpisode?.duration = duration
        }
        
        return item
    }
}
