//
//  PodcastFullEpisodeList.swift
//  Books
//
//  Created by Rasmus Krämer on 01.02.23.
//

import SwiftUI

extension DetailView {
    struct PodcastFullEpisodeList: View {
        @Namespace var namespace
        
        var episodes: [LibraryItem.PodcastEpisode]
        var item: LibraryItem
        
        @State var sort: (EpisodeSort, Bool) = (FilterHelper.defaultSortOrder, FilterHelper.defaultInvert)
        @State var filter: EpisodeFilter = FilterHelper.defaultFilter
        
        @State var query: String = ""
        
        @State var activeSeasonIndex: Int?
        @State var activeSeason: Int?
        @State var seasons = [Int]()
        
        var fallback: some View {
            Text("No episodes")
                .bold()
        }
        
        var body: some View {
            VStack {
                if episodes.count == 0 {
                    fallback
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            let filtered = FilterHelper.filterEpisodes(FilterHelper.sortEpisodes(episodes.filter { episode in
                                if query != "" && !(episode.title ?? "").localizedStandardContains(query) {
                                    return false
                                }
                                if activeSeason == nil {
                                    return true
                                }
                                
                                if let season = episode.season, let season = Int(season) {
                                    return season == activeSeason
                                }
                                
                                return false
                            }, sort), filter: filter)
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
                        .contentTransition(ContentTransition.interpolate)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Episodes")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, placement: .navigationBarDrawer)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(EpisodeSort.allCases, id: \.rawValue) { sort in
                            Button {
                                Haptics.shared.play(.light)
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
                            Haptics.shared.play(.light)
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
                                Haptics.shared.play(.light)
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
            .safeAreaInset(edge: .top) {
                if seasons.count > 1 {
                    PillSelector(activeIndex: $activeSeasonIndex, items: seasons.map({ "Season \($0)" }), pillWidth: 80)
                        .onChange(of: activeSeasonIndex) { _ in
                            if let activeSeasonIndex = activeSeasonIndex {
                                activeSeason = seasons[activeSeasonIndex]
                            }
                        }
                        .frame(height: 30)
                        .padding(.vertical, 5)
                        .background(.ultraThickMaterial)
                        .toolbarBackground(.ultraThickMaterial, for: .navigationBar)
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
                    // i hate this
                    if let season = episode.season, season != "", let season = Int(season) {
                        if !seasons.contains(season) {
                            seasons.append(season)
                        }
                    }
                    
                    // i haven't found a podcast where a episode has no season, so i will not implement this
                    // if episode.season == nil || episode.season == ""
                }
                seasons.sort()
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
