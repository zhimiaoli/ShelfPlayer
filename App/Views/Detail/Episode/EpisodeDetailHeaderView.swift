//
//  EpisodeDetailHeaderView.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 18.02.23.
//

import SwiftUI

struct EpisodeDetailHeaderView: View {
    let item: LibraryItem
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            ItemImage(item: item, size: 165)
                .padding(.top, 150)
            
            HStack {
                if let publishedAt = item.recentEpisode?.publishedAt {
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
                    
                    Text("•")
                    ProgressIndicator(completedPercentage: PersistenceController.shared.getProgressByLibraryItem(item: item))
                        .frame(height: 13)
                    
                    Text("•")
                    Text(TextHelper.formatTime(tourple: Date.secondsToHoursMinutesSeconds(Int(item.recentEpisode?.length ?? 0))))
                }
            }
            .font(.caption)
            .fontDesign(.rounded)
            .foregroundColor(.gray)
            
            Group {
                Text(item.title)
                    .padding(.top, item.isLocal ?? false ? 10 : 1)
                    .font(.title3)
                    .bold()
                
                if !(item.isLocal ?? false) {
                    NavigationLink(destination: DetailView(id: item.id)) {
                        HStack {
                            Text(item.media?.metadata.title ?? "unknown podcast")
                                .lineLimit(1)
                            Image(systemName: "chevron.right.circle")
                                .dynamicTypeSize(.xSmall)
                        }
                        .font(.callout)
                        .foregroundColor(.primary)
                    }
                }
            }
            .frame(maxWidth: 325)
            .multilineTextAlignment(.center)
            
            ItemButtons(item: item, colorScheme: colorScheme)
                .padding(.bottom, 25)
        }
    }
}
