//
//  PodcastDetailInner.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

extension DetailView {
    struct PodcastDetailInner: View {
        let item: LibraryItem
        
        @EnvironmentObject private var fullscreenViewModel: FullscrenViewViewModel
        
        @State private var backgroundIsLight: Bool = UIColor.systemBackground.isLight() ?? false
        
        var body: some View {
            VStack {
                VStack {
                    ItemImage(item: item, size: 225)
                        .onBecomingVisible {
                            fullscreenViewModel.hideNavigationBar()
                        }
                        .onBecomingInvisible {
                            fullscreenViewModel.showNavigationBar()
                        }
                    
                    VStack {
                        Text(item.title)
                            .padding(.top, 1)
                            .font(.title3)
                            .bold()
                        
                        Text(item.author)
                            .font(.callout)
                            .foregroundColor((backgroundIsLight ? Color.black : Color.white).opacity(0.7))
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 250)
                    
                    Button {
                        // TODO: play item
                    } label: {
                        Label("Play latest episode", systemImage: "play.fill")
                    }
                    .buttonStyle(PlayNowButtonStyle(colorScheme: backgroundIsLight ? .dark : .light))
                    
                    VStack(alignment: .leading) {
                        let html = item.media?.metadata.description ?? "No description..."
                        
                        Text(TextHelper.parseHTML(html))
                            .lineLimit(3)
                            .padding(.bottom)
                            .font(.subheadline)
                        
                        HStack {
                            let explict = item.media?.metadata.explicit ?? false
                            if explict {
                                Image(systemName: "e.square")
                            }
                            if let count = item.media?.episodes?.count {
                                if explict {
                                    Text("•")
                                }
                                
                                Image(systemName: "number")
                                Text(String(count))
                                    .padding(.leading, -6)
                                
                                if item.media?.metadata.genres.count ?? 0 > 0 {
                                    Text("•")
                                }
                            }
                            if let genres = item.media?.metadata.genres {
                                Text(genres.joined(separator: ", "))
                            }
                            
                            Spacer()
                        }
                        .foregroundColor((backgroundIsLight ? Color.black : Color.white).opacity(0.7))
                        .font(.caption)
                    }
                    .padding()
                }
                .padding(.top, 100)
                .background(Color(fullscreenViewModel.backgroundColor))
                .foregroundColor(backgroundIsLight ? .black : .white)
                
                PodcastDetailEpisodeList(episodes: item.media?.episodes ?? [])
                    .frame(minHeight: fullscreenViewModel.mainContentMinHeight, alignment: .top)
            }
            .navigationTitle(item.title)
            .frame(maxWidth: .infinity)
            .task {
                (fullscreenViewModel.backgroundColor, backgroundIsLight) = await ImageHelper.getAverageColor(item: item)
            }
        }
    }
}
