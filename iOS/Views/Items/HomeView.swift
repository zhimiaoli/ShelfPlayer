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
                                if index == 0 || rows[index - 1].id != "continue-series" {
                                    Divider()
                                        .padding(.horizontal)
                                }
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
                .onChange(of: globalViewModel.activeLibraryId) { _ in
                    Task {
                        await loadRows()
                    }
                }
            }
            .navigationTitle("Listen now")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    LibraryPicker()
                }
            }
        } else {
            FullscreenLoadingIndicator(description: "Loading")
                .task(loadRows)
        }
    }
    
    @Sendable private func loadRows() async {
        rows = try? await APIClient.authorizedShared.request(APIResources.libraries(id: globalViewModel.activeLibraryId).personalized)
    }
}
