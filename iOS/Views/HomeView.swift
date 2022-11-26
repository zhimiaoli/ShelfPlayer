//
//  Home.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var rows: [PersonalizedLibraryRow]?
    
    var body: some View {
        if let rows = rows {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                        if index == 0 {
                            ItemRowContainer() {
                                var entities = row.entities
                                
                                if let first = entities.removeFirst() {
                                    ItemRow(title: "Latest", content: [first])
                                }
                                if entities.count > 0 {
                                    ItemRow(title: row.label, content: entities)
                                }
                            }
                        } else {
                            if colorScheme == .dark {
                                Divider()
                                    .padding(.horizontal)
                            }
                            
                            ItemRowContainer(title: row.label) {
                                ItemRow(content: row.entities)
                            }
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
