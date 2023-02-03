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
    public func createDownload(itemId: String, episodeId: String?, ext: String, index: Int, identifier: Int) {
        let download = Download(context: PersistenceController.shared.container.viewContext)
        download.forItem = DownloadHelper.getIdentifier(itemId: itemId, episodeId: episodeId)
        download.itemId = itemId
        download.episodeId = episodeId
        
        download.ext = ext
        download.index = Int16(index)
        download.identifier = Int16(identifier)
        
        try? PersistenceController.shared.container.viewContext.save()
    }
    
    public func getDownloadCache() -> [Download] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Download")
        
        if let entities = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest) as? [Download] {
            return entities
        }
        
        return []
    }
    public func getDownloadByIdentifier(_ identifier: Int) -> (String, Int, String, String?, String)? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Download")
        request.predicate = NSPredicate(format: "identifier == %i", identifier)
        request.fetchLimit = 1
        
        do {
            let result = try container.viewContext.fetch(request)
            guard let download = result.first as? Download else {
                return nil
            }
            
            let id = download.forItem!
            let index = download.index
            
            return (id, Int(index), download.itemId ?? "_", download.episodeId, download.ext ?? "mp3")
        } catch {
            return nil
        }
    }
    public func deleteDownloadByIdentifier(_ identifier: Int) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Download")
        request.predicate = NSPredicate(format: "identifier == %i", identifier)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        let _ = try? container.viewContext.execute(deleteRequest)
    }
    
    public func getLocalItems() -> [LocalItem] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LocalItem")
        
        if let entities = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest) as? [LocalItem] {
            return entities
        }
        
        return []
    }
    public func getLocalItem(itemId: String, episodeId: String?) -> LocalItem? {
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
            return first
        }
        
        return nil
    }
    
    public func setLocalConflict(itemId: String, episodeId: String?) {
        let item = getLocalItem(itemId: itemId, episodeId: episodeId)
        
        item?.hasConflict = true
        try? container.viewContext.save()
    }
    
    public func removeAllLocalItems() {
        var fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LocalItem")
        var deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let _ = try? container.viewContext.execute(deleteRequest)
        
        fetchRequest = NSFetchRequest(entityName: "Download")
        deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let _ = try? container.viewContext.execute(deleteRequest)
    }
}
