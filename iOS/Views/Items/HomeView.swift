//
//  Home.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

/// Home view containing a curated list of items fetched from the server
struct HomeView: View {
    @EnvironmentObject var globalViewModel: GlobalViewModel
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
                            
                            ItemRowContainer(title: row.label, appearence: row.type == "authors" ? .smaller : .normal) {
                                ItemRow(content: row.entities)
                            }
                            
                            if row.id == "continue-series" {
                                NavigationLink(destination: SeriesView()) {
                                    SeriesBanner()
                                        .padding(.top, -18)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Listen now")
        } else {
            FullscreenLoadingIndicator(description: "Loading")
                .task {
                    rows = try? await APIClient.authorizedShared.request(APIResources.libraries(id: globalViewModel.activeLibraryId).personalized)
                }
        }
    }
}
