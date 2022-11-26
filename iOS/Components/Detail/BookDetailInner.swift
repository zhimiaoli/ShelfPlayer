//
//  BookDetailInner.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import SwiftUI

struct BookDetailInner: View {
    var item: LibraryItem
    @Binding var presentationMode: PresentationMode
    
    @State private var isNavigationBarVisible: Bool = false
    @State private var animateNavigationBarChanges: Bool = false
    
    @State private var backgroundColor = UIColor.secondarySystemBackground
    @State private var backgroundIsLight = UIColor.secondarySystemBackground.isLight() ?? false
    
    @State private var seriesName: String?
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    ItemImage(id: item.id, size: 300)
                        .shadow(radius: 10)
                        .onBecomingVisible {
                            if !animateNavigationBarChanges {
                                isNavigationBarVisible = false
                                return
                            }
                            
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isNavigationBarVisible = false
                            }
                        }
                        .onBecomingInvisible {
                            if !animateNavigationBarChanges {
                                isNavigationBarVisible = true
                                return
                            }
                            
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isNavigationBarVisible = true
                            }
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                self.animateNavigationBarChanges = true
                            }
                        }
                    
                    VStack {
                        Text(item.media?.metadata.title ?? "unknown title")
                            .font(.system(.headline, design: .serif))
                        if let author = item.media?.metadata.authorName {
                            Text(author)
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Button {
                                
                            } label: {
                                Label("Listen now", systemImage: "play.fill")
                            }
                            .buttonStyle(PlayNowButtonStyle(colorScheme: backgroundIsLight ? .dark : .light))
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "arrow.down")
                            }
                            Button {
                                
                            } label: {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .padding()
                    .buttonStyle(SecondaryButtonStyle(colorScheme: backgroundIsLight ? .dark : .light))
                    .foregroundColor(backgroundIsLight ? .black : .white)
                }
                .padding(.top, 100)
                .frame(maxWidth: .infinity, alignment: .top)
                .background(Color(backgroundColor))
                
                VStack(alignment: .leading) {
                    if let description = item.media?.metadata.description {
                        Text("Description")
                            .font(.system(.headline, design: .serif))
                            .padding(.bottom, 7)
                            .underline()
                        Text(description)
                        
                        Divider()
                            .padding(.vertical, 20)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: [GridItem()]) {
                            if let narrator = item.media?.metadata.narratorName {
                                if narrator != "" {
                                    Group {
                                        ItemDetailGridItem(title: "Narrator", summary: narrator.components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.first!)") + ($1 == "" ? "" : "\($1.first!)") }, description: narrator)
                                        Divider()
                                    }
                                }
                            }
                            if let duration = item.duration {
                                Group {
                                    ItemDetailGridItem(title: "Duration", summary: Date.secondsToHoursMinutes(duration), description: "hrs:min")
                                    Divider()
                                }
                            }
                            if let publisher = item.media?.metadata.publisher {
                                Group {
                                    ItemDetailGridItem(title: "Publisher", summary: publisher.components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.first!)") + "\($1.first!)" }, description: publisher)
                                    Divider()
                                }
                            }
                            if let chapters = item.numChapters, let tracks = item.numTracks {
                                Group {
                                    ItemDetailGridItem(title: "Chapter\(chapters == 1 ? "" : "s")", summary: String(chapters), description: "\(tracks) Track\(tracks == 1 ? "" : "s")")
                                    Divider()
                                }
                            }
                            if let seriesName = item.media?.metadata.seriesName?.split(separator: " #") {
                                // TODO: Navigate to series
                                Group {
                                    // NavigationLink(destination: Text("oof")) {
                                    ItemDetailGridItem(title: "Series", summary: seriesName.count > 1 ? "#\(seriesName[1])" : "Extra", description: seriesName[0].description)
                                    Divider()
                                    // }
                                }
                            }
                            if let size = item.size {
                                Group {
                                    ItemDetailGridItem(title: "Size", summary: ByteCountFormatter().string(fromByteCount: Int64(size)), description: "on disk")
                                    Divider()
                                }
                            }
                            if let addedAt = Int64(item.addedAt) {
                                ItemDetailGridItem(title: "Added", summary: Date(milliseconds: addedAt).formatted(.dateTime.day().month()), description: Date(milliseconds: addedAt).formatted(.dateTime.year()))
                            }
                        }
                    }
                    .frame(height: 60)
                    
                    Divider()
                        .padding(.vertical, 20)
                }
                .padding(.horizontal)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .top)
                .background(.background)
                
                if let seriesName = seriesName, let libraryId = item.libraryId {
                    BookDetailSeries(name: seriesName, library: libraryId)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationTitle(item.media?.metadata.title ?? "unknown title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isNavigationBarVisible ? .visible : .hidden, for: .navigationBar)
        .overlay(CustomBackButton(presentationMode: $presentationMode, visible: !isNavigationBarVisible))
        .modifier(GestureSwipeRight(action: {
            if presentationMode.isPresented && !isNavigationBarVisible {
                withAnimation {
                    presentationMode.dismiss()
                }
            }
        }))
        .task {
            (backgroundColor, backgroundIsLight) = await ImageHelper.getAverageColor(id: item.id)
        }
        .onAppear {
            if let series = item.media?.metadata.seriesName {
                if series.contains("#") {
                    seriesName = series.split(separator: " #")[0].description
                } else {
                    seriesName = series
                }
            }
        }
    }
}
