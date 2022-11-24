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
    
    func deleteAllCachedSessions() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedMediaProgress")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try container.viewContext.execute(deleteRequest)
    }
}
