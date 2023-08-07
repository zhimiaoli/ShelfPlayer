//
//  NowPlayingSheet.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

extension NowPlayingWrapper {
    struct NowPlayingSheet: View {
        @EnvironmentObject var viewModel: ViewModel
        @EnvironmentObject var globalViewModel: GlobalViewModel
        
        @State var playing: Bool = PlayerHelper.audioPlayer?.isPlaying() ?? false
        
        var body: some View {
            GeometryReader { proxy in
                VStack {
                    VStack {
                        ItemImage(item: globalViewModel.currentlyPlaying, size: proxy.size.width - (playing ? 0 : 40))
                            .shadow(radius: 25)
                            .padding(.top, 10)
                            .animation(.bouncy, value: playing)
                    }
                    .frame(height: proxy.size.width)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            if globalViewModel.currentlyPlaying!.isPodcast {
                                if let publishedAt = globalViewModel.currentlyPlaying!.recentEpisode?.publishedAt {
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
                                    .font(.caption2)
                                    .foregroundColor(.primaryTransparent)
                                    .fontDesign(.rounded)
                                }
                            }
                            
                            Text(globalViewModel.currentlyPlaying!.title)
                                .font(.system(size: 21, weight: .bold, design: .libraryFontDesign(globalViewModel.activeLibraryType)))
                                .foregroundColor((viewModel.backgroundIsLight ? Color.black : Color.white))
                            Text(globalViewModel.currentlyPlaying!.author)
                                .bold()
                                .padding(.top, -12)
                                .foregroundColor((viewModel.backgroundIsLight ? Color.black : Color.white).opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    SeekSlider(isBook: globalViewModel.currentlyPlaying!.isBook)
                        .padding(.top, 10)
                    
                    NowPlayingButtons()
                        .frame(maxHeight: .infinity)
                    
                    VolumeSlider()
                    NowPlayingFooterButtons()
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(25)
            .background {
                ZStack {
                    Rectangle()
                        .fill(Color(viewModel.backgroundColor).gradient)
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
                .ignoresSafeArea()
            }
            .environment(\.colorScheme, viewModel.backgroundIsLight ? .light : .dark)
            .edgesIgnoringSafeArea(.bottom)
            .onReceive(NSNotification.PlayerStateChanged, perform: { _ in
                playing = PlayerHelper.audioPlayer?.isPlaying() ?? false
            })
        }
    }
}
