//
//  Persistence+MediaProgress.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import Foundation
import CoreData

extension PersistenceController {
    // MARK: - Bulk operations
    public func updateMediaProgressDatabase(_ updated: [MediaProgress]) {
        syncEntities()
        
        updated.forEach { mediaProgress in
            let cachedMediaProgress = {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedMediaProgress")
                fetchRequest.predicate = NSPredicate(format: "id == %@", mediaProgress.id)
                
                guard let objects = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest), let first = objects.first as? CachedMediaProgress else {
                    return CachedMediaProgress(context: PersistenceController.shared.container.viewContext)
                }
                
                return first
            }()
            
            if cachedMediaProgress.lastUpdate?.millisecondsSince1970 ?? 0 > Int64(mediaProgress.lastUpdate ?? 0) {
                cachedMediaProgress.duration = mediaProgress.duration ?? 0
                try? PersistenceController.shared.container.viewContext.save()
            } else if cachedMediaProgress.lastUpdate?.millisecondsSince1970 ?? 0 != Int64(mediaProgress.lastUpdate ?? 0) {
                cachedMediaProgress.id = mediaProgress.id
                cachedMediaProgress.libraryItemId = mediaProgress.libraryItemId
                cachedMediaProgress.episodeId = mediaProgress.episodeId
                cachedMediaProgress.hideFromContinueListening = mediaProgress.hideFromContinueListening
                
                cachedMediaProgress.isFinished = mediaProgress.isFinished
                cachedMediaProgress.currentTime = mediaProgress.currentTime ?? 0
                cachedMediaProgress.duration = mediaProgress.duration ?? 0
                cachedMediaProgress.progress = mediaProgress.progress ?? 0
                
                if let finishedAt = mediaProgress.finishedAt {
                    cachedMediaProgress.finishedAt = Date(milliseconds: Int64(finishedAt))
                }
                if let lastUpdate = mediaProgress.lastUpdate {
                    cachedMediaProgress.lastUpdate = Date(milliseconds: Int64(lastUpdate))
                }
                if let startedAt = mediaProgress.startedAt {
                    cachedMediaProgress.startedAt = Date(milliseconds: Int64(startedAt))
                }
                
                try? PersistenceController.shared.container.viewContext.save()
            }
        }
    }
    public func deleteAllCachedSessions() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedMediaProgress")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        try container.viewContext.execute(deleteRequest)
    }
    
    public func getUpdatedEntities() -> [CachedMediaProgress] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedMediaProgress")
        fetchRequest.predicate = NSPredicate(format: "localUpdate == YES")
        
        if let entities = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest) as? [CachedMediaProgress] {
            return entities
        }
        
        return []
    }
    public func syncEntities() {
        getUpdatedEntities().forEach { updatedProgress in
            Task {
                do {
                    if !(updatedProgress.currentTime.isNaN || updatedProgress.currentTime.isInfinite || updatedProgress.progress.isNaN || updatedProgress.progress.isInfinite) {
                        NSLog("Found updated progress \(updatedProgress.id ?? "?") \(updatedProgress.progress) \(updatedProgress.duration)")
                        try await APIClient.authorizedShared.request(APIResources.me.syncLocalProgress(updatedProgress))
                        
                        updatedProgress.localUpdate = false
                        try container.viewContext.save()
                    }
                } catch {
                    NSLog("Failed to sync entities")
                    print(error)
                }
            }
        }
    }
    
    // MARK: - Progress
    public func getProgressByLibraryItem(item: LibraryItem, required: Bool = false) -> Float {
        let entity = getEnitityByLibraryItem(item: item)
        return Float(entity?.progress ?? 0)
    }
    public func getProgressByPodcastEpisode(episode: LibraryItem.PodcastEpisode, required: Bool = false) -> Float {
        let entity = getEntityByPodcastEpisode(episode: episode)
        return Float(entity?.progress ?? 0)
    }
    
    public func updateStatus(itemId: String, episodeId: String?, currentTime: Double, duration: Double) {
        let entity = getEnitityById(itemId: itemId, episodeId: episodeId, required: true)
        
        entity?.currentTime = currentTime
        entity?.duration = duration
        entity?.isFinished = currentTime >= duration
        entity?.progress = currentTime / duration
        
        entity?.lastUpdate = Date()
        entity?.localUpdate = true
        
        try? container.viewContext.save()
    }
    public func updateStatusWithoutUpdate(item: LibraryItem, progress: Float) {
        let entity = getEnitityByLibraryItem(item: item, required: true)
        
        entity?.progress = Double(progress)
        entity?.isFinished = progress == 1
        entity?.currentTime = (entity?.duration ?? 0) * Double(progress)
        
        try? container.viewContext.save()
    }
    public func updateStatusWithoutUpdate(itemId: String, episodeId: String?, currentTime: Double, progress: Float, duration: Double) {
        let entity = getEnitityById(itemId: itemId, episodeId: episodeId, required: true)
        
        entity?.currentTime = currentTime
        entity?.progress = Double(progress)
        entity?.duration = duration
        entity?.isFinished = progress == 1
        
        try? container.viewContext.save()
    }
    
    // MARK: - Getter
    public func getEnitityByLibraryItem(item: LibraryItem, required: Bool = false) -> CachedMediaProgress? {
        if !item.isBook && !(item.isPodcast && item.hasEpisode) {
            return nil
        }
        
        return getEnitityById(itemId: item.id, episodeId: item.recentEpisode?.id, required: required)
    }
    public func getEntityByPodcastEpisode(episode: LibraryItem.PodcastEpisode, required: Bool = false) -> CachedMediaProgress? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedMediaProgress")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "libraryItemId == %@", episode.libraryItemId ?? ""),
            NSPredicate(format: "episodeId == %@", episode.id ?? ""),
        ])
        
        guard let objects = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest), let first = objects.first as? CachedMediaProgress else {
            if !required {
                return nil
            }
            
            let mediaProgress = CachedMediaProgress(context: container.viewContext)
            
            mediaProgress.id = "\(episode.libraryItemId ?? "_")-\(episode.id ?? "_")"
            mediaProgress.libraryItemId = episode.libraryItemId ?? "_"
            mediaProgress.episodeId = episode.id ?? "_"
            mediaProgress.hideFromContinueListening = false
            
            mediaProgress.isFinished = false
            mediaProgress.currentTime = 0
            mediaProgress.progress = 0
            mediaProgress.duration = episode.duration ?? 0
            
            try? PersistenceController.shared.container.viewContext.save()
            return mediaProgress
        }
        
        return first
    }
    public func getEnitityById(itemId: String, episodeId: String?, required: Bool = false) -> CachedMediaProgress? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedMediaProgress")
        if let episodeId = episodeId {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "libraryItemId == %@", itemId),
                NSPredicate(format: "episodeId == %@", episodeId),
            ])
        } else {
            fetchRequest.predicate = NSPredicate(format: "libraryItemId == %@", itemId)
        }
        
        guard let objects = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest), let first = objects.first as? CachedMediaProgress else {
            if !required {
                return nil
            }
            
            let mediaProgress = CachedMediaProgress(context: container.viewContext)
            
            if let episodeId = episodeId {
                mediaProgress.id = "\(itemId)-\(episodeId)"
                mediaProgress.episodeId = episodeId
            } else {
                mediaProgress.id = itemId
            }
            mediaProgress.libraryItemId = itemId
            mediaProgress.hideFromContinueListening = false
            
            mediaProgress.isFinished = false
            mediaProgress.currentTime = 0
            mediaProgress.progress = 0
            mediaProgress.duration = 0
            
            try? PersistenceController.shared.container.viewContext.save()
            return mediaProgress
        }
        
        return first
    }
}
