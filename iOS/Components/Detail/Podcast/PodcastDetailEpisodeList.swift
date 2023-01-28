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
        
        var body: some View {
            VStack {
                if episodes.count == 0 {
                    Text("No episodes")
                        .bold()
                } else {
                    HStack {
                        Text("Episodes")
                            .font(.title3)
                        Spacer()
                        NavigationLink(destination: Text("uwu")) {
                            Text("See all")
                        }
                    }
                    
                    LazyVStack(alignment: .leading) {
                        ForEach(Array(episodes.prefix(15)), id: \.id) { episode in
                            Divider()
                            
                            VStack(alignment: .leading) {
                                if let publishedAt = episode.publishedAt {
                                    let date = Date(milliseconds: Int64(publishedAt))
                                    
                                    Group {
                                        if Calendar.current.isDateInToday(date) {
                                            Text("TODAY")
                                        } else if Calendar.current.isDateInYesterday(date) {
                                            Text("YESTERDAY")
                                        } else {
                                            Text(date.formatted(.dateTime.day().month(.wide).year()))
                                        }
                                    }
                                    .foregroundColor(.primary.opacity(0.7))
                                    .font(.caption)
                                }
                                Text(episode.title ?? "?")
                                    .bold()
                                    .lineSpacing(20)
                                
                                Text(TextHelper.parseHTML(episode.description ?? "no description"))
                                    .font(.subheadline)
                                    .lineLimit(3)
                                
                                HStack {
                                    let (h, m, s) = Date.secondsToHoursMinutesSeconds(Int(episode.duration ?? 0))
                                    
                                    Image(systemName: "play.circle.fill")
                                        .dynamicTypeSize(.xxLarge)
                                    if h == "00" {
                                        Text("\(m):\(s)")
                                    } else {
                                        Text("\(h):\(m)")
                                    }
                                }
                                .bold()
                                .padding(.top, 0.5)
                                .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}
