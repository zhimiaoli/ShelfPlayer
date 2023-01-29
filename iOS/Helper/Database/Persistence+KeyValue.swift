//
//  Persistence+KeyValue.swift
//  Books
//
//  Created by Rasmus Krämer on 29.01.23.
//

import Foundation
import CoreData

extension PersistenceController {
    func getValue(key: String) -> String? {
        getKeyValue(key)?.value
    }
    
    func setKey(_ key: String, value: String) {
        let keyValue = getKeyValue(key) ?? KeyValue(context: container.viewContext)
        
        keyValue.key = key
        keyValue.value = value
        
        try? container.viewContext.save()
    }
    
    func deleteKey(_ key: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "KeyValue")
        fetchRequest.predicate = NSPredicate(format: "key == %@", key)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let _ = try? container.viewContext.execute(deleteRequest)
    }
    
    func flushKeyValueStorage() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "KeyValue")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        let _ = try? container.viewContext.execute(deleteRequest)
    }
    
    // MARK: - private functions
    private func getKeyValue(_ key: String) -> KeyValue? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "KeyValue")
        request.predicate = NSPredicate(format: "key == %@", key)
        request.fetchLimit = 1
        
        do {
            let result = try container.viewContext.fetch(request)
            return result.first as? KeyValue
        } catch {
            return nil
        }
    }
}
