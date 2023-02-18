//
//  LibraryItem+Episodes.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 18.02.23.
//

import Foundation

extension LibraryItem {
    /// Get the unique identifier of the item
    var identifier: String {
        recentEpisode?.id ?? id
    }
    
    /// Returns the title of the item
    var title: String {
        recentEpisode?.title ?? media?.metadata.title ?? name ?? "unknown title"
    }
    /// Returns the author of the item
    var author: String {
        media?.metadata.authorName ?? media?.metadata.author ?? "unknown author"
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
    
    /// Returns a Boolean value indicating whether the item is a (audio)book
    var isBook: Bool {
        mediaType == "book"
    }
    /// Returns a Boolean value indicating whether the item is a podcast or episode
    var isPodcast: Bool {
        mediaType == "podcast"
    }
    /// Returns a Boolean value indicating whether the item is a series
    var isSeries: Bool {
        id.starts(with: "ser_")
    }
    /// Returns a Boolean value indicating whether the item is an author
    var isAuthor: Bool {
        numBooks != nil
    }
    /// Returns a Boolean value indicating whether the item is a podcast and has a episode
    var hasEpisode: Bool {
        recentEpisode != nil
    }
    
    /// Returns a Boolean value indicating whether the item is a avaiable offline
    var isDownloaded: Bool {
        isLocal ?? false
    }
}
