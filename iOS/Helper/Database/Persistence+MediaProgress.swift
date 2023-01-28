//
//  Persistence+MediaProgress.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import Foundation
import CoreData

extension PersistenceController {
    public func updateMediaProgressDatabase(_ updated: [MediaProgress]) {
        updated.forEach { mediaProgress in
            let cachedMediaProgress = {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedMediaProgress")
                fetchRequest.predicate = NSPredicate(format: "id == %@", mediaProgress.id)
                
                guard let objects = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest), let first = objects.first as? CachedMediaProgress else {
                    return CachedMediaProgress(context: PersistenceController.shared.container.viewContext)
                }
                
                return first
            }()
            
            if cachedMediaProgress.lastUpdate?.millisecondsSince1970 ?? 0 < Int64(mediaProgress.lastUpdate ?? 0) {
                cachedMediaProgress.id = mediaProgress.id
                cachedMediaProgress.libraryItemId = mediaProgress.libraryItemId
                cachedMediaProgress.episodeId = mediaProgress.episodeId
                cachedMediaProgress.isFinished = mediaProgress.isFinished
                cachedMediaProgress.hideFromContinueListening = mediaProgress.hideFromContinueListening
                
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
                
                do {
                    try PersistenceController.shared.container.viewContext.save()
                } catch {
                    print("Failed to cache media progress", error)
                }
            }
        }
    }
    
    public func deleteAllCachedSessions() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedMediaProgress")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try container.viewContext.execute(deleteRequest)
    }
    
    public func getProgressByLibraryItem(item: LibraryItem) -> Float {
        let entity = getEnitityByLibraryItem(item: item)
        return Float(entity?.progress ?? 0)
    }
    
    public func updateStatusWithoutUpdate(item: LibraryItem, progress: Float) {
        let entity = getEnitityByLibraryItem(item: item)
        
        entity?.progress = Double(progress)
        try? container.viewContext.save()
    }
    
    private func getEnitityByLibraryItem(item: LibraryItem) -> CachedMediaProgress? {
        if !item.isBook && !(item.isPodcast && item.hasEpisode) {
            return nil
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedMediaProgress")
        if item.hasEpisode {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "libraryItemId == %@", item.id),
                NSPredicate(format: "episodeId == %@", item.recentEpisode?.id ?? ""),
            ])
        } else {
            fetchRequest.predicate = NSPredicate(format: "libraryItemId == %@", item.id)
        }
        
        guard let objects = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest), let first = objects.first as? CachedMediaProgress else {
            return nil
        }
        
        return first
    }
}
