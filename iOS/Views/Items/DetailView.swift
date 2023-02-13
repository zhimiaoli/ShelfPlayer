//
//  DetailView.swift
//  Books
//
//  Created by Rasmus Krämer on 25.11.22.
//

import SwiftUI

/// Detailed view of a item
struct DetailView: View {
    var id: String?
    var item: LibraryItem?
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State var failed: Bool = false
    @State var currentItem: LibraryItem?
    
    var body: some View {
        if let item = currentItem {
            if item.isBook {
                FullscreenView(viewModel: FullscrenViewViewModel(title: item.title)) {
                    BookDetailInner(viewModel: ViewModel(item: item))
                } menu: {}
            } else if item.isPodcast {
                if item.hasEpisode {
                    FullscreenView(viewModel: FullscrenViewViewModel(title: item.title)) {
                        EpisodeDetailInner(item: item)
                    } menu: {}
                } else if item.media?.episodes != nil {
                    FullscreenView(viewModel: FullscrenViewViewModel(title: item.title)) {
                        PodcastDetailInner(item: item)
                    } menu: {
                        PodcastSettingsSheet(item: item)
                    }
                    .id(item.id)
                } else {
                    FullscreenLoadingIndicator(description: "Retriving episodes")
                        .onAppear {
                            Task.detached {
                                await getItem()
                            }
                        }
                }
            } else if item.isSeries {
                GridDetailInner(item: item, scope: "series")
            } else if item.isAuthor {
                GridDetailInner(item: item, scope: "authors")
            }
        } else {
            if failed {
                Text("Error")
                    .bold()
                    .foregroundColor(Color.red)
            } else {
                FullscreenLoadingIndicator(description: "Retriving item")
                    .onAppear {
                        Task.detached {
                            await getItem()
                        }
                    }
            }
        }
    }
    
    @Sendable private func getItem() async {
        if currentItem == nil && item != nil {
            currentItem = item
            return
        }
        
        do {
            if let id = id, id.starts(with: "ser_") {
                currentItem = try await APIClient.authorizedShared.request(APIResources.series.byId(id: id))
            } else {
                currentItem = try await APIClient.authorizedShared.request(APIResources.items(id: id ?? item?.id ?? "").get)
            }
        } catch {
            failed = true
        }
    }
}
