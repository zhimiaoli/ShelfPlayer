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
            VStack(alignment: .leading, spacing: 2) {
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
                    Button {
                        
                    } label: {
                        Image(systemName: "play.circle.fill")
                        // .dynamicTypeSize(.xxLarge)
                    }
                    
                    Group {
                        Text(TextHelper.formatTime(tourple: Date.secondsToHoursMinutesSeconds(Int(episode.duration ?? 0))))
                    }
                    .font(.subheadline)
                }
                .bold()
                .padding(.top, 4)
                .foregroundColor(.accentColor)
            }
        }
    }
}

/*
struct Previews_PodcastDetailListEpisode_Previews: PreviewProvider {
    static var previews: some View {
        PodcastDetailListEpisode(episode: LibraryItem.PodcastEpisode(id: "test", libraryItemId: "test", index: 0, season: nil, episode: nil, title: "Episode title", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", publishedAt: 1675017968697, addedAt: 1675017968697, updatedAt: 1675017968697, size: 345345344, duration: 780000))
            .padding()
    }
}
*/
