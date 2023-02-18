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
        
        if episodeId != nil {
            let episode = LibraryItem.PodcastEpisode(id: episodeId, libraryItemId: itemId, title: episodeTitle, description: episodeDescription, duration: duration)
            item.recentEpisode = episode
        }
        
        return item
    }
}
