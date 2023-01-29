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
                FullscreenView(presentationMode: presentationMode) {
                    BookDetailInner(viewModel: ViewModel(item: item))
                } menu: {}
            } else if item.isPodcast {
                if item.hasEpisode {
                    FullscreenView(presentationMode: presentationMode) {
                        EpisodeDetailInner(item: item)
                    } menu: {}
                } else if item.media?.episodes != nil {
                    FullscreenView(presentationMode: presentationMode) {
                        PodcastDetailInner(item: item)
                    } menu: {
                        PodcastSettingsSheet(item: item)
                    }
                    .id(item.id)
                } else {
                    FullscreenLoadingIndicator(description: "Retriving episodes")
                        .task(getItem)
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
                    .task(getItem)
            }
        
        Text(String(currentItem?.media?.episodes?.count ?? -1))
        }
    }
    
    @Sendable private func getItem() async {
        if currentItem == nil && item != nil {
            currentItem = item
            return
        }
        
        do {
            let retrivedItem = try await APIClient.authorizedShared.request(APIResources.items(id: id ?? item?.id ?? "").get)
            currentItem = retrivedItem
        } catch {
            failed = true
        }
    }
}
