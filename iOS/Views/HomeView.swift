//
//  Home.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct HomeView: View {
    @State private var rows: [PersonalizedLibraryRow]?
    
    var body: some View {
        if let rows = rows {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(rows) { row in
                        ItemRowContainer {
                            ItemRow(title: row.label, content: row.entities)
                        }
                    }
                }
            }
            .navigationTitle("Listen now")
        } else {
            FullscreenLoadingIndicator(description: "Loading")
                .task(loadContent)
        }
    }
    
    @Sendable private func loadContent() async {
        rows = try! await APIClient.authorizedShared.request(APIResources.libraries(id: PersistenceController.shared.getLoggedInUser()!.lastActiveLibraryId!).personalized)
    }
}
