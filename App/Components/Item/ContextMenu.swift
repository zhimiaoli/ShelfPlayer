//
//  ContextMenu.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 02.06.23.
//

import SwiftUI

struct ContextMenu: ViewModifier {
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    var item: LibraryItem
    
    func body(content: Content) -> some View {
        content
            .contextMenu(menuItems: {
                if item.isBook || item.hasEpisode {
                    Button {
                        Haptics.shared.play(.light)
                        Task.detached {
                            await item.toggleFinishedStatus()
                        }
                    } label: {
                        Label("Toggle finished", systemImage: "checkmark")
                    }
                    
                    Button {
                        Haptics.shared.play(.medium)
                        Task.detached {
                            await DownloadHelper.downloadItem(item: item)
                        }
                    } label: {
                        Label("Download", systemImage: "arrow.down")
                    }
                    
                    Button {
                        globalViewModel.playItem(item: item)
                        Haptics.shared.play(.medium)
                    } label: {
                        Label("Play", systemImage: "play.fill")
                    }
                }
                // TODO: Show series contents
            }, preview: {
                HStack(alignment: .top) {
                    ItemImage(item: item, size: 100)
                        .padding(.trailing, 10)
                    
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.headline)
                            .fontDesign(.libraryFontDesign(globalViewModel.activeLibraryType))
                        
                        Group {
                            Group {
                                Text(item.author)
                                
                                if let duration = item.media?.duration {
                                    let (h, m, _) = Date.secondsToHoursMinutesSeconds(Int(duration))
                                    Text("Duration: \(h):\(m)")
                                }
                            }
                            .font(.caption)
                            
                            Spacer()
                            
                            HStack {
                                // Podcasts
                                Group {
                                    if let seasonData = item.recentEpisode?.seasonData, seasonData.0 != nil {
                                        Text("S\(seasonData.0 ?? "?") E\(seasonData.1 ?? "?")")
                                        Text("•")
                                    }
                                    
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
                                    }
                                }
                                
                                // Books
                                Group {
                                    if let narrator = item.media?.metadata.narratorName, narrator != "" {
                                        Text("Narrated by \(narrator)")
                                        Text("•")
                                    }
                                    
                                    if let chapters = item.media?.numChapters {
                                        Text("\(chapters) Chapters")
                                    }
                                }
                            }
                            .font(.caption2)
                        }
                        .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .frame(height: 100)
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .cornerRadius(7)
                .background(.background)
            })
    }
}
