//
//  ItemRowItem.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct ItemRowItem: View {
    var item: LibraryItem
    var size: CGFloat?
    var shadow: Bool = false
    
    @State var progressPercentage: Float = 0
    @State var actualSize: CGFloat = 175
    
    @Environment(\.itemRowItemWidth) var itemRowItemWidth
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    var body: some View {
        NavigationLink(destination: DetailView(item: item)) {
            VStack(alignment: item.isAuthor ? .center : .leading) {
                Image(item: item, size: actualSize, shadow: 2)
                
                HStack {
                    Text(verbatim: item.title)
                        .font(.caption)
                        .bold()
                        .tint(.primary)
                    
                    if !item.isAuthor {
                        Spacer()
                    }
                    
                    if progressPercentage > 0 {
                        if progressPercentage >= 1 {
                            Text("100%")
                                .font(.system(.caption, design: .rounded).smallCaps())
                                .foregroundColor(Color.gray)
                        } else {
                            ProgressIndicator(completedPercentage: progressPercentage)
                        }
                    } else if let numBooks = item.numBooks {
                        Text(String(numBooks))
                            .font(.system(.caption, design: .rounded).smallCaps())
                            .foregroundColor(Color.gray)
                            .offset(y: -1)
                    }
                }
                .frame(height: 15)
            }
            .frame(width: actualSize)
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
                    Image(item: item, size: 100, shadow: 10)
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
                .padding(20)
                .cornerRadius(7)
                .background(.background)
            })
        }
        .buttonStyle(.plain)
        .onAppear {
            progressPercentage = PersistenceController.shared.getProgressByLibraryItem(item: item)
            actualSize = size ?? itemRowItemWidth.wrappedValue
        }
        .onChange(of: itemRowItemWidth.wrappedValue) { _ in
            actualSize = size ?? itemRowItemWidth.wrappedValue
        }
    }
    
    struct Image: View {
        var item: LibraryItem
        var size: CGFloat
        var shadow: CGFloat
        
        var body: some View {
            if !item.isSeries {
                ItemImage(item: item, size: size)
            } else {
                if let books = item.books, books.count > 0 {
                    Group {
                        if books.count == 1 {
                            ItemImage(item: books[0], size: size)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                                if books.count <= 3 {
                                    let even = item.title.count % 2 == 0
                                    
                                    if even {
                                        Spacer()
                                    }
                                    ItemImage(item: books[0], size: size / 2)
                                        .offset(x: even ? -10 : 10, y: 10)
                                    if !even {
                                        Spacer()
                                        Spacer()
                                    }
                                    ItemImage(item: books[1], size: size / 2)
                                        .offset(x: even ? 10 : -10, y: -10)
                                } else {
                                    let gridItemSize = (size / 2) - 4
                                    
                                    ItemImage(item: books[0], size: gridItemSize)
                                    ItemImage(item: books[1], size: gridItemSize)
                                    ItemImage(item: books[2], size: gridItemSize)
                                    ItemImage(item: books[3], size: gridItemSize)
                                }
                            }
                        }
                    }
                    .background(.gray.opacity(0.1))
                    .cornerRadius(7)
                    .shadow(radius: shadow)
                } else {
                    ItemImage(item: nil, size: size)
                }
            }
        }
    }
}
