//
//  EpisodeDetailInner.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

struct EpisodeDetailView: View {
    let item: LibraryItem
    
    @StateObject var fullscreenViewModel: FullscrenViewViewModel
    
    init(item: LibraryItem) {
        _fullscreenViewModel = StateObject(wrappedValue: FullscrenViewViewModel(title: item.title))
        self.item = item
    }
    
    var body: some View {
        FullscreenView(header: {
            EpisodeDetailHeaderView(item: item)
        }, content: {
            VStack(alignment: .leading) {
                if let html = item.recentEpisode?.description {
                    Text(TextHelper.parseHTML(html))
                }
                
                if !item.isDownloaded {
                    EpisodeAbout(item: item)
                }
            }
            .padding()
        }, background: {
            LinearGradient(colors: [Color(fullscreenViewModel.backgroundColor), Color(UIColor.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
        })
        .onAppear {
            Task.detached {
                let backgroundColor = await item.getAverageColor().0.withAlphaComponent(0.7)
                
                DispatchQueue.main.async {
                    fullscreenViewModel.backgroundColor = backgroundColor
                }
            }
        }
        .environmentObject(fullscreenViewModel)
    }
}
