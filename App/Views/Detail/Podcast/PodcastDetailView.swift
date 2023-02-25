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
        @StateObject var fullscreenViewModel: FullscrenViewViewModel
        
        init(item: LibraryItem) {
            _fullscreenViewModel = StateObject(wrappedValue: FullscrenViewViewModel(title: item.title))
            useBackgroundImage = item.getUseBackgroundImage()
            
            self.item = item
        }
        
        @EnvironmentObject var globalViewModel: GlobalViewModel
        
        @State var backgroundIsLight: Bool = UIColor.systemBackground.isLight() ?? false
        @State var latestEpisode: LibraryItem.PodcastEpisode?
        @State var useBackgroundImage: Bool
        
        var body: some View {
            FullscreenView(header: {
                VStack {
                    if !useBackgroundImage {
                        ItemImage(item: item, size: 225)
                            .shadow(radius: 25)
                            .padding(.top, 100)
                    }
                    
                    Spacer()
                    VStack {
                        VStack {
                            Text(item.title)
                                .padding(.top, useBackgroundImage ? 300 : 1)
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
                    .background {
                        if useBackgroundImage {
                            LinearGradient(stops: [
                                Gradient.Stop(color: Color(fullscreenViewModel.backgroundColor).opacity(0.0), location: 0.0),
                                Gradient.Stop(color: Color(fullscreenViewModel.backgroundColor).opacity(0.5), location: 0.25),
                                Gradient.Stop(color: Color(fullscreenViewModel.backgroundColor), location: 1),
                            ], startPoint: .top, endPoint: .bottom)
                            .padding(.top, 225)
                        }
                    }
                }
                .foregroundColor(backgroundIsLight ? .black : .white)
            }, content: {
                PodcastDetailEpisodeList(episodes: item.media?.episodes ?? [], item: item, latestEpisode: $latestEpisode)
            }, background: {
                Group {
                    if useBackgroundImage {
                        ItemImage(item: item, size: .infinity)
                    } else {
                        Color(fullscreenViewModel.backgroundColor)
                    }
                }
            }, menu: {
                AnyView(erasing: PodcastSettingsSheet(item: item))
            })
            .onAppear {
                Task.detached {
                    let (backgroundColor, backgroundIsLight) = await item.getAverageColor()
                    
                    DispatchQueue.main.async {
                        fullscreenViewModel.backgroundColor = backgroundColor
                        self.backgroundIsLight = backgroundIsLight
                    }
                }
            }
            .onReceive(NSNotification.PodcastSettingsUpdated) { _ in
                useBackgroundImage = item.getUseBackgroundImage()
            }
            .environmentObject(fullscreenViewModel)
        }
    }
}
