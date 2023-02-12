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
        @Environment(\.defaultMinListRowHeight) var minRowHeight
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
                            
                            if let progress = PersistenceController.shared.getProgressByLibraryItem(item: item) {
                                Text("•")
                                ProgressIndicator(completedPercentage: progress)
                                    .frame(height: 13)
                            }
                            
                            Text("•")
                            Text(TextHelper.formatTime(tourple: Date.secondsToHoursMinutesSeconds(Int(item.recentEpisode?.length ?? 0))))
                        }
                    }
                    .font(.caption)
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
                .frame(maxWidth: .infinity)
                .background {
                    // It is not possible to animate this
                    LinearGradient(colors: [Color(fullscreenViewModel.backgroundColor), Color(UIColor.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                }
                
                VStack(alignment: .leading) {
                    if let html = item.recentEpisode?.description {
                        Text(TextHelper.parseHTML(html))
                    }
                    
                    if !(item.isLocal ?? false) {
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
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: fullscreenViewModel.mainContentMinHeight, alignment: .topLeading)
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
