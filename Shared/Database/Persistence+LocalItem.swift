//
//  Persistence+LocalItem.swift
//  Books
//
//  Created by Rasmus Krämer on 02.02.23.
//

import Foundation
import CoreData

extension PersistenceController {
    public func createLocalItem(item: LibraryItem) {
        let entitiy = LocalItem(context: container.viewContext)
        
        entitiy.itemId = item.id
        entitiy.episodeId = item.recentEpisode?.id
        
        entitiy.duration = item.media?.duration ?? item.recentEpisode?.duration ?? 0
        
        if item.hasEpisode {
            entitiy.title = item.title
        }
        entitiy.author = item.author
    }
}
