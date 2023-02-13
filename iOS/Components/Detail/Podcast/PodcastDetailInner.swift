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
        @EnvironmentObject private var globalViewModel: GlobalViewModel
        
        @State private var backgroundIsLight: Bool = UIColor.systemBackground.isLight() ?? false
        @State private var latestEpisode: LibraryItem.PodcastEpisode?
        
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
                    
                    if let latestEpisode = latestEpisode {
                        Button {
                            globalViewModel.playItem(item: {
                                var withEpisode = item
                                withEpisode.recentEpisode = latestEpisode
                                
                                return withEpisode
                            }())
                        } label: {
                            let progress = PersistenceController.shared.getProgressByPodcastEpisode(episode: latestEpisode)
                            Label("\(progress > 0 && progress < 1 ? "Resume" : "Play") latest episode", systemImage: "play.fill")
                        }
                        .buttonStyle(PlayNowButtonStyle(colorScheme: backgroundIsLight ? .dark : .light))
                    }
                    
                    VStack(alignment: .leading) {
                        if let html = item.media?.metadata.description {
                            LineLimitView(text: TextHelper.parseHTML(html), title: item.title, limit: 3)
                                .padding(.bottom)
                                .font(.subheadline)
                        }
                        
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
                            HStack(spacing: 0) {
                                if let genres = item.media?.metadata.genres {
                                    let last = genres.last
                                    ForEach(genres, id: \.hashValue) { genre in
                                        NavigationLink(destination: GenreView(genre: genre)) {
                                            Text(genre)
                                                .lineLimit(1)
                                        }
                                        
                                        if genre != last {
                                            Text(", ")
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .foregroundColor((backgroundIsLight ? Color.black : Color.white).opacity(0.7))
                        .font(.caption)
                        .fontDesign(.rounded)
                    }
                    .padding()
                }
                .padding(.top, 100)
                .background(Color(fullscreenViewModel.backgroundColor))
                .foregroundColor(backgroundIsLight ? .black : .white)
                
                PodcastDetailEpisodeList(episodes: item.media?.episodes ?? [], item: item, latestEpisode: $latestEpisode)
                    .frame(minHeight: fullscreenViewModel.mainContentMinHeight, alignment: .top)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .onAppear {
                Task.detached {
                    let (backgroundColor, backgroundIsLight) = await ImageHelper.getAverageColor(item: item)
                    
                    DispatchQueue.main.async {
                        fullscreenViewModel.backgroundColor = backgroundColor
                        self.backgroundIsLight = backgroundIsLight
                    }
                }
            }
        }
    }
}
