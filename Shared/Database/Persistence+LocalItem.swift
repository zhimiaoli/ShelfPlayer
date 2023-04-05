//
//  Persistence+LocalItem.swift
//  Books
//
//  Created by Rasmus Krämer on 02.02.23.
//

import Foundation
import CoreData

extension PersistenceController {
    public func createDownloadTrack(itemId: String, episodeId: String?, duration: Double, ext: String, index: Int, identifier: Int) {
        let download = DownloadTrack(context: PersistenceController.shared.container.viewContext)
        download.forItem = DownloadHelper.getIdentifier(itemId: itemId, episodeId: episodeId)
        download.itemId = itemId
        download.episodeId = episodeId
        
        download.ext = ext
        download.index = Int16(index)
        download.identifier = Int16(identifier)
        download.duration = duration
        download.isDownloaded = false
        
        try? PersistenceController.shared.container.viewContext.save()
    }
    
    public func getDownloadedTracks() -> [DownloadTrack] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "DownloadTrack")
        
        if let entities = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest) as? [DownloadTrack] {
            return entities
        }
        
        return []
    }
    public func getDownloadedTracks(id: String) -> [DownloadTrack] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "DownloadTrack")
        fetchRequest.predicate = NSPredicate(format: "forItem == %@", id)
        
        if let entities = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest) as? [DownloadTrack] {
            return entities
        }
        
        return []
    }
    public func getDownloadTrackByIdentifier(_ identifier: Int) -> (String, Int, String, String?, String)? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadTrack")
        request.predicate = NSPredicate(format: "identifier == %i", identifier)
        request.fetchLimit = 1
        
        do {
            let result = try container.viewContext.fetch(request)
            guard let download = result.first as? DownloadTrack else {
                return nil
            }
            
            let id = download.forItem!
            let index = download.index
            
            return (id, Int(index), download.itemId!, download.episodeId, download.ext ?? "mp3")
        } catch {
            return nil
        }
    }
    
    public func markTrackAsDownloaded(_ identifier: Int) {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadTrack")
            request.predicate = NSPredicate(format: "identifier == %i", identifier)
            request.fetchLimit = 1
            
            if let result = try container.viewContext.fetch(request).first as? DownloadTrack {
                result.isDownloaded = true
                result.identifier = -1
                try? container.viewContext.save()
            }
        } catch {
            NSLog("Failed to mark entity as downloaded")
        }
    }
    public func removeTrackIdentifier(_ identifier: Int) {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadTrack")
            request.predicate = NSPredicate(format: "identifier == %i", identifier)
            request.fetchLimit = 1
            
            if let result = try container.viewContext.fetch(request).first as? DownloadTrack {
                result.identifier = -1
                try! container.viewContext.save()
            }
        } catch {
            NSLog("Failed to remove track identifier")
        }
    }
    public func deleteTracks(id: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "DownloadTrack")
        fetchRequest.predicate = NSPredicate(format: "forItem == %@", id)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let _ = try! container.viewContext.execute(deleteRequest)
    }
    
    public func getLocalItems() -> [LocalItem] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LocalItem")
        
        if let entities = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest) as? [LocalItem] {
            entities.forEach { entity in
                entity.verify()
            }
            return entities
        }
        
        return []
    }
    public func getLocalItem(itemId: String, episodeId: String?, verify: Bool = true) -> LocalItem? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LocalItem")
        fetchRequest.fetchLimit = 1
        
        if let episodeId = episodeId {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "itemId == %@", itemId),
                NSPredicate(format: "episodeId == %@", episodeId),
            ])
        } else {
            fetchRequest.predicate = NSPredicate(format: "itemId == %@", itemId)
        }
        
        if let entities = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest) as? [LocalItem], let first = entities.first {
            if verify {
                first.verify()
            }
            return first
        }
        
        return nil
    }
    
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
    public func deleteLocalItem(itemId: String, episodeId: String?) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LocalItem")
        if let episodeId = episodeId {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "itemId == %@", itemId),
                NSPredicate(format: "episodeId == %@", episodeId),
            ])
        } else {
            fetchRequest.predicate = NSPredicate(format: "itemId == %@", itemId)
        }
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let _ = try! container.viewContext.execute(deleteRequest)
    }
    public func setLocalConflict(itemId: String, episodeId: String?) {
        let item = getLocalItem(itemId: itemId, episodeId: episodeId, verify: false)
        
        item?.hasConflict = true
        try! container.viewContext.save()
    }
    public func setDownloadStatus(itemId: String, episodeId: String?, downloaded: Bool) {
        let item = getLocalItem(itemId: itemId, episodeId: episodeId, verify: false)
        
        item?.isDownloaded = downloaded
        try! container.viewContext.save()
    }
    
    public func removeAllLocalItems() {
        var fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LocalItem")
        var deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let _ = try! container.viewContext.execute(deleteRequest)
        
        fetchRequest = NSFetchRequest(entityName: "DownloadTrack")
        deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let _ = try! container.viewContext.execute(deleteRequest)
    }
}
