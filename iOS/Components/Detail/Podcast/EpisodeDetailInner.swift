//
//  EpisodeDetailInner.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

extension DetailView {
    struct EpisodeDetailInner: View {
        let item: LibraryItem
        
        @EnvironmentObject private var fullscreenViewModel: FullscrenViewViewModel
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            VStack {
                VStack {
                    ItemImage(item: item, size: 165)
                        .padding(.top, 150)
                        .onBecomingVisible {
                            fullscreenViewModel.hideNavigationBar()
                        }
                        .onBecomingInvisible {
                            fullscreenViewModel.showNavigationBar()
                        }
                    
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
                            Text(TextHelper.formatTime(tourple: Date.secondsToHoursMinutesSeconds(Int(item.recentEpisode?.duration ?? 0))))
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    
                    Group {
                        Text(item.title)
                            .padding(.top, 1)
                            .font(.title3)
                            .bold()
                        
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
                    .frame(maxWidth: 325)
                    .multilineTextAlignment(.center)
                    
                    ItemButtons(item: item, colorScheme: colorScheme)
                        .padding(.bottom, 25)
                }
                .frame(maxWidth: .infinity)
                .background {
                    // It is apparently not possible to animate this
                    LinearGradient(colors: [Color(fullscreenViewModel.backgroundColor), Color(UIColor.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                }
                
                VStack {
                    if let html = item.recentEpisode?.description {
                        Text(TextHelper.parseHTML(html))
                    }
                }
                .padding()
                .frame(minHeight: fullscreenViewModel.mainContentMinHeight, alignment: .top)
            }
            .navigationTitle(item.title)
            .onAppear {
                Task.detached {
                    let backgroundColor = await ImageHelper.getAverageColor(item: item).0.withAlphaComponent(0.7)
                    
                    DispatchQueue.main.async {
                        fullscreenViewModel.backgroundColor = backgroundColor
                    }
                }
            }
        }
    }
}
