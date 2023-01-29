//
//  PodcastDetailEpisodeList.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

extension DetailView {
    struct PodcastDetailEpisodeList: View {
        var episodes: [LibraryItem.PodcastEpisode]
        
        init(episodes: [LibraryItem.PodcastEpisode]) {
            self.episodes = episodes
            self.filter = episodes.count == 0 ? .all : FilterHelper.getDefaultFilter(podcastId: episodes[0].libraryItemId ?? "")
        }
        
        @State var filter: EpisodeFilter
        
        var fallback: some View {
            Text("No episodes")
                .bold()
        }
        
        var body: some View {
            VStack {
                if episodes.count == 0 {
                    fallback
                } else {
                    HStack {
                        Menu {
                            ForEach(EpisodeFilter.allCases, id: \.rawValue) { filter in
                                Button {
                                    withAnimation {
                                        self.filter = filter
                                    }
                                } label: {
                                    Text(filter.rawValue)
                                }
                            }
                        } label: {
                            HStack {
                                Text(filter.rawValue)
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                
                                Image(systemName: "chevron.down")
                            }
                            .bold()
                        }
                        Spacer()
                        NavigationLink(destination: Text("uwu")) {
                            Text("See all")
                                .bold()
                        }
                    }
                    
                    LazyVStack(alignment: .leading) {
                        let filtered = Array(FilterHelper.sortEpisodes(FilterHelper.filterEpisodes(episodes, filter: filter), sortOrder: .date, invert: true).prefix(15))
                        
                        if filtered.count > 0 {
                            ForEach(filtered, id: \.id) { episode in
                                Divider()
                                PodcastDetailListEpisode(episode: episode)
                            }
                        } else {
                            VStack(alignment: .center) {
                                fallback
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding()
        }
    }
}
