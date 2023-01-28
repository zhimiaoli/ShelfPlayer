//
//  EpisodeDetailInner.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI
import SwiftSoup

extension DetailView {
    struct EpisodeDetailInner: View {
        let item: LibraryItem
        
        @EnvironmentObject private var fullscreenViewModel: FullscrenViewViewModel
        @Environment(\.colorScheme) var colorScheme
        
        @State private var description: String?
        
        var body: some View {
            VStack {
                VStack {
                    ItemImage(item: item, size: 165)
                        .padding(.top, 150)
                    
                    if let publishedAt = item.recentEpisode?.publishedAt {
                        Text(Date(milliseconds: Int64(publishedAt)).formatted(.dateTime.day().month(.wide).year()))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Group {
                        Text(item.title)
                            .padding(.top, 1)
                            .font(.title3)
                            .bold()
                        
                        NavigationLink(destination: DetailView(id: item.id)) {
                            HStack {
                                Text(item.media?.metadata.title ?? "unknown podcast")
                                Image(systemName: "chevron.right.circle")
                                    .dynamicTypeSize(.xSmall)
                            }
                            .font(.callout)
                            .foregroundColor(.primary)
                        }
                    }
                    .frame(maxWidth: 275)
                    .multilineTextAlignment(.center)
                    
                    ItemButtons(item: item, colorScheme: colorScheme)
                        .padding(.bottom, 25)
                }
                .frame(maxWidth: .infinity)
                .background {
                    LinearGradient(colors: [Color(fullscreenViewModel.backgroundColor), Color(UIColor.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                }
                
                VStack {
                    if let description = description {
                        Text(description)
                        Text(description)
                    }
                }
                .padding()
                .frame(minHeight: fullscreenViewModel.mainContentMinHeight, alignment: .top)
            }
            .navigationTitle(item.title)
            .task {
                fullscreenViewModel.backgroundColor = await ImageHelper.getAverageColor(item: item).0.withAlphaComponent(0.7)
            }
            .onAppear {
                if let html = item.recentEpisode?.description {
                    do {
                        let cleaned = try SwiftSoup.clean(html, Whitelist.basic())!
                        let document: Document = try SwiftSoup.parse(cleaned)
                        description = try document.text()
                    } catch {
                        description = "error while parsing description"
                    }
                }
            }
        }
    }
}
