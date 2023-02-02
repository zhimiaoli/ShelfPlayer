//
//  PodcastFullEpisodeList.swift
//  Books
//
//  Created by Rasmus Krämer on 01.02.23.
//

import SwiftUI

extension DetailView {
    struct PodcastFullEpisodeList: View {
        var episodes: [LibraryItem.PodcastEpisode]
        var item: LibraryItem
        
        @State var sort: (EpisodeSort, Bool) = (FilterHelper.defaultSortOrder, FilterHelper.defaultInvert)
        @State var filter: EpisodeFilter = FilterHelper.defaultFilter
        
        @State private var activeSeason: String?
        @State private var seasons = [String]()
        
        var fallback: some View {
            Text("No episodes")
                .bold()
        }
        
        var body: some View {
            VStack {
                if episodes.count == 0 {
                    fallback
                } else {
                    if seasons.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach(seasons.sorted(by: { $0 < $1 }), id: \.hashValue) { season in
                                    Button {
                                        if activeSeason == season {
                                            activeSeason = nil
                                        } else {
                                            activeSeason = season
                                        }
                                    } label: {
                                        PodcastDetailPill(text: "Season \(season)", active: activeSeason == season)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 30)
                    }
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading) {
                            let filtered = FilterHelper.sortEpisodes(FilterHelper.filterEpisodes(episodes, filter: filter), sort).filter { episode in
                                if activeSeason == nil {
                                    return true
                                }
                                
                                return episode.season == activeSeason
                            }
                            if filtered.count > 0 {
                                ForEach(Array(filtered.enumerated()), id: \.offset) { index, episode in
                                    if (seasons.count < 1 && index != 0) || index > 0 {
                                        Divider()
                                    }
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
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Episodes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(EpisodeSort.allCases, id: \.rawValue) { sort in
                            Button {
                                withAnimation {
                                    self.sort.0 = sort
                                }
                            } label: {
                                if self.sort.0 == sort {
                                    Label(sort.rawValue, systemImage: "checkmark")
                                } else {
                                    Text(sort.rawValue)
                                }
                            }
                        }
                        
                        Divider()
                        
                        Button {
                            withAnimation {
                                self.sort.1 = !self.sort.1
                            }
                        } label: {
                            if self.sort.1 == true {
                                Label("Invert", systemImage: "checkmark")
                            } else {
                                Text("Invert")
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(EpisodeFilter.allCases, id: \.rawValue) { filter in
                            Button {
                                withAnimation {
                                    self.filter = filter
                                }
                            } label: {
                                if self.filter == filter {
                                    Label(filter.rawValue, systemImage: "checkmark")
                                } else {
                                    Text(filter.rawValue)
                                }
                            }
                        }
                    } label: {
                        if filter == .all {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        } else {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        }
                    }
                }
            }
            .onReceive(NSNotification.PodcastSettingsUpdated) { _ in
                updateFilter()
            }
            .onReceive(NSNotification.ItemUpdated) { _ in
                updateFilter(forceUpdate: true)
            }
            .onAppear {
                updateFilter()
                
                episodes.forEach { episode in
                    if let season = episode.season, season != "" {
                        if !seasons.contains(season) {
                            seasons.append(season)
                        }
                    }
                    
                    // i haven't found a podcast where a episode has no season, so i will not implement this
                    // print(episode.season == nil || episode.season == "")
                }
            }
        }
        
        private func updateFilter(forceUpdate: Bool = false) {
            if forceUpdate {
                self.sort = (self.sort.0, !self.sort.1)
            }
            
            self.filter = FilterHelper.getDefaultFilter(podcastId: item.id)
            self.sort = FilterHelper.getDefaultSortOrder(podcastId: item.id)
        }
    }
}
