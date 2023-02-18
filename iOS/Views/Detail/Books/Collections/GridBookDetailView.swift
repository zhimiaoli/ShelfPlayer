//
//  BookDetailGrid.swift
//  Books
//
//  Created by Rasmus Krämer on 27.01.23.
//

import SwiftUI

extension DetailView {
    /// Grid cotaining small pieces of information of a book
    struct BookDetailGrid: View {
        @EnvironmentObject private var viewModel: ViewModel
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem()]) {
                    if let narrator = viewModel.item.media?.metadata.narratorName {
                        if narrator != "" {
                            Group {
                                ItemDetailGridItem(title: "Narrator", summary: narrator.components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.first!)") + ($1 == "" ? "" : "\($1.first!)") }, description: narrator)
                                Divider()
                            }
                        }
                    }
                    if let duration = viewModel.item.media?.duration {
                        Group {
                            let (h, m, _) = Date.secondsToHoursMinutesSeconds(Int(duration))
                            
                            ItemDetailGridItem(title: "Duration", summary: "\(h):\(m)", description: "hrs:min")
                            Divider()
                        }
                    }
                    if let publisher = viewModel.item.media?.metadata.publisher {
                        Group {
                            ItemDetailGridItem(title: "Publisher", summary: publisher.components(separatedBy: " ").reduce("") {
                                $1.first == nil ? $0 : ($0 + "\($1.first!)")
                            }, description: publisher)
                            Divider()
                        }
                    }
                    if let chapters = viewModel.item.media?.numChapters, let tracks = viewModel.item.media?.numTracks {
                        Group {
                            ItemDetailGridItem(title: "Chapter\(chapters == 1 ? "" : "s")", summary: String(chapters), description: "\(tracks) Track\(tracks == 1 ? "" : "s")")
                            Divider()
                        }
                    }
                    if let seriesName = viewModel.item.media?.metadata.seriesName?.split(separator: " #"), seriesName.count > 0 {
                        Group {
                            let gridItem = ItemDetailGridItem(title: "Series", summary: seriesName.count > 1 ? "#\(seriesName[1])" : "Extra", description: seriesName[0].description)
                            if let seriesId = viewModel.seriesId {
                                NavigationLink(destination: DetailView(id: seriesId)) {
                                    gridItem
                                }
                            } else {
                                gridItem
                            }
                            
                            Divider()
                        }
                    }
                    if let size = viewModel.item.size {
                        Group {
                            ItemDetailGridItem(title: "Size", summary: ByteCountFormatter().string(fromByteCount: Int64(size)), description: "on disk")
                            Divider()
                        }
                    }
                    if let addedAt = viewModel.item.addedAt {
                        ItemDetailGridItem(title: "Added", summary: Date(milliseconds: Int64(addedAt)).formatted(.dateTime.day().month()), description: Date(milliseconds: Int64(addedAt)).formatted(.dateTime.year()))
                    }
                }
            }
            .frame(height: 60)
        }
    }
}
