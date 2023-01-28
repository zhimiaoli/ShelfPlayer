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
                    
                    Text("9. Januar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
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
                    }
                }
                .padding()
                .frame(minHeight: fullscreenViewModel.mainContentMinHeight, alignment: .top)
            }
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
