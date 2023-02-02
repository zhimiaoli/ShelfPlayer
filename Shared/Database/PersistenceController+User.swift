//
//  PersistenceController+User.swift
//  Books
//
//  Created by Rasmus Krämer on 15.11.22.
//

import Foundation
import CoreData

extension PersistenceController {
    func getLoggedInUser() -> User? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.fetchLimit = 1
        
        do {
            let result = try container.viewContext.fetch(request)
            return result.first as? User
        } catch {
            return nil
        }
    }
    
    func deleteLoggedInUser() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try container.viewContext.execute(deleteRequest)
    }
}
