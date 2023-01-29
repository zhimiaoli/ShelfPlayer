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
        
        var body: some View {
            VStack(alignment: .leading) {
                if let publishedAt = episode.publishedAt {
                    let date = Date(milliseconds: Int64(publishedAt))
                    
                    Group {
                        if Calendar.current.isDateInToday(date) {
                            Text("TODAY")
                        } else if Calendar.current.isDateInYesterday(date) {
                            Text("YESTERDAY")
                        } else {
                            Text(date.formatted(.dateTime.day().month(.wide).year()).uppercased())
                        }
                    }
                    .foregroundColor(.primaryTransparent)
                    .bold()
                    .font(.caption)
                }
                Text(episode.title ?? "?")
                    .font(.headline)
                    .bold()
                
                if let html = episode.description {
                    Text(TextHelper.parseHTML(html))
                        .font(.subheadline)
                        .foregroundColor(.primaryTransparent)
                        .lineLimit(3)
                }
                
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
