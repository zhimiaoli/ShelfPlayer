//
//  BooksApp.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI

@main
struct BooksApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
