//
//  PodcastDetailListEpisode.swift
//  Books
//
//  Created by Rasmus Krämer on 29.01.23.
//

import SwiftUI

extension DetailView {
    struct PodcastDetailListEpisode: View {
        var episode: LibraryItem.PodcastEpisode
        var item: LibraryItem
        
        @EnvironmentObject var globalViewModel: GlobalViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if let publishedAt = episode.publishedAt {
                        let date = Date(milliseconds: Int64(publishedAt))
                        
                        Group {
                            if Calendar.current.isDateInToday(date) {
                                Text("Today")
                            } else if Calendar.current.isDateInYesterday(date) {
                                Text("Yesterday")
                            } else {
                                Text(date.formatted(.dateTime.day().month(.wide).year()))
                            }
                        }
                    }
                    
                    if let season = episode.seasonData.season, let episodeInSeason = episode.seasonData.episode {
                        if episode.publishedAt != nil {
                            Text("•")
                        }
                        Text("S\(season)E\(episodeInSeason)")
                    }
                }
                .foregroundColor(.primaryTransparent)
                .bold()
                .font(.system(.subheadline).smallCaps())
                .fontDesign(.rounded)
                
                Text(episode.title ?? "?")
                    .font(.headline)
                    .bold()
                
                if let html = episode.description {
                    Text(TextHelper.parseHTML(html))
                        .font(.subheadline)
                        .foregroundColor(.primaryTransparent)
                        .lineLimit(3)
                }
                
                Button {
                    globalViewModel.playItem(item: {
                        var withEpisode = item
                        withEpisode.recentEpisode = episode
                        
                        return withEpisode
                    }())
                } label: {
                    Image(systemName: "play.circle.fill")
                        .dynamicTypeSize(.xxxLarge)
                        .symbolRenderingMode(.hierarchical)
                    
                    Group {
                        if let entity = PersistenceController.shared.getEntityByPodcastEpisode(episode: episode), entity.progress > 0 {
                            if entity.progress < 1 {
                                Text(TextHelper.formatTime(tourple: Date.secondsToHoursMinutesSeconds(Int(entity.duration - entity.currentTime)))) + Text(" remaining")
                            } else {
                                Text(TextHelper.formatTime(tourple: Date.secondsToHoursMinutesSeconds(Int(entity.duration - entity.currentTime))))
                                    .foregroundColor(.primaryTransparent)
                            }
                        } else {
                            Text(TextHelper.formatTime(tourple: Date.secondsToHoursMinutesSeconds(Int(episode.duration ?? 0))))
                        }
                    }
                    .font(.subheadline)
                }
                .bold()
                .padding(.top, 4)
                .foregroundColor(.accentColor)
            }
            .padding(.vertical, 5)
        }
    }
}
