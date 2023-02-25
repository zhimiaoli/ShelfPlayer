//
//  EpisodeAboutView.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 18.02.23.
//

import SwiftUI

struct EpisodeAbout: View {
    let item: LibraryItem
    
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    var body: some View {
        DisclosureGroup {
            VStack {
                Group {
                    ListItem(title: "Title", text: item.title)
                    ListItem(title: "Podcast", text: item.media?.metadata.title ?? "unknown podcast")
                    ListItem(title: "Author", text: item.author)
                    ListItem(title: "Size", text: ByteCountFormatter().string(fromByteCount: Int64(item.recentEpisode?.audioFile?.metadata?.size ?? 0)))
                    
                    if let seasonData = item.recentEpisode?.seasonData, seasonData.0 != nil {
                        ListItem(title: "Series", text: "Season: \(seasonData.0 ?? "?") | Episode: \(seasonData.1 ?? "?")")
                    }
                }
                Group {
                    ListItem(title: "Duration", text: TextHelper.formatTime(tourple: Date.secondsToHoursMinutesSeconds(Int(item.recentEpisode?.length ?? 0))))
                    ListItem(title: "Codec", text: item.recentEpisode?.audioFile?.codec ?? "?")
                    ListItem(title: "Channels", text: item.recentEpisode?.audioFile?.channelLayout ?? "?")
                }
            }
            .fontDesign(.rounded)
            .listStyle(.inset)
            .frame(minHeight: minRowHeight * (item.recentEpisode?.seasonData.0 == nil ? 7 : 8), alignment: .topLeading)
        } label: {
            Text("About")
                .font(.title2)
                .bold()
                .padding(.vertical)
                .foregroundColor(.primary)
        }
    }
    
    private struct ListItem: View {
        let title: String
        let text: String
        
        var body: some View {
            Divider()
            HStack {
                Text(title)
                    .foregroundColor(.gray)
                Spacer()
                Text(text)
            }
        }
    }
}
