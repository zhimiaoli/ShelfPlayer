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
        var item: LibraryItem
        
        @State var sort: (EpisodeSort, Bool) = (FilterHelper.defaultSortOrder, FilterHelper.defaultInvert)
        @State var filter: EpisodeFilter = FilterHelper.defaultFilter
        
        @State var filteredEpisodes = [LibraryItem.PodcastEpisode]()
        @Binding var latestEpisode: LibraryItem.PodcastEpisode?
        
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
                                    
                                    updateEpisodes()
                                } label: {
                                    if self.filter == filter {
                                        Label(filter.rawValue, systemImage: "checkmark")
                                    } else {
                                        Text(filter.rawValue)
                                    }
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
                        NavigationLink(destination: PodcastFullEpisodeList(episodes: episodes, item: item)) {
                            Text("See all")
                                .bold()
                        }
                    }
                    
                    LazyVStack(alignment: .leading) {
                        if filteredEpisodes.count > 0 {
                            ForEach(filteredEpisodes, id: \.id) { episode in
                                Divider()
                                NavigationLink {
                                    DetailView(item: {
                                        var withPodcast = item
                                        withPodcast.recentEpisode = episode
                                        
                                        return withPodcast
                                    }())
                                } label: {
                                    PodcastDetailListEpisode(episode: episode, item: item)
                                }
                                .buttonStyle(.plain)
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
            .onReceive(NSNotification.PodcastSettingsUpdated) { _ in
                updateFilter()
            }
            .onReceive(NSNotification.ItemUpdated) { _ in
                updateFilter(reset: true)
            }
            .onAppear {
                updateFilter()
                updateEpisodes()
            }
        }
        
        private func updateFilter(reset: Bool = false) {
            if reset {
                self.sort = (self.sort.0, !self.sort.1)
            }
            
            self.filter = FilterHelper.getDefaultFilter(podcastId: item.id)
            self.sort = FilterHelper.getDefaultSortOrder(podcastId: item.id)
            
            updateEpisodes()
        }
        private func updateEpisodes() {
            filteredEpisodes = Array(
                FilterHelper.sortEpisodes(
                    FilterHelper.filterEpisodes(
                        episodes,
                        filter: filter),
                    sort
                ).prefix(15))
            
            Task.detached {
                latestEpisode = FilterHelper.sortEpisodes(FilterHelper.filterEpisodes(episodes, filter: filter), sort).first
            }
        }
    }
}
