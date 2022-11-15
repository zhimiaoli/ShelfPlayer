//
//  Persistence.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Books")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func getLoggedInUser() -> User? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.fetchLimit = 1
        
        do {
            let result = try container.viewContext.fetch(request)
            return result.first! as? User
        } catch {
            return nil
        }
    }
}
