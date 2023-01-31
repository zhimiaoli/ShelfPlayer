//
//  NowPlayingSheet.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

extension NowPlayingWrapper {
    struct NowPlayingSheet: View {
        @EnvironmentObject private var viewModel: ViewModel
        @EnvironmentObject private var globalViewModel: GlobalViewModel
        
        var body: some View {
            GeometryReader { proxy in
                VStack {
                    ItemImage(item: globalViewModel.currentlyPlaying, size: proxy.size.width)
                        .shadow(radius: 10)
                        .padding(.vertical, 10)
                    // this does not work
                    // .matchedGeometryEffect(id: "image", in: namespace)
                    
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
                                }
                            }
                            
                            Text(globalViewModel.currentlyPlaying!.title)
                                .font(.system(size: 21, weight: .bold, design: .serif))
                                .foregroundColor((viewModel.backgroundIsLight ? Color.black : Color.white))
                            Text(globalViewModel.currentlyPlaying!.author)
                                .bold()
                                .padding(.top, -12)
                                .foregroundColor((viewModel.backgroundIsLight ? Color.black : Color.white).opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    
                    SeekSlider(isBook: globalViewModel.currentlyPlaying!.isBook)
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    VolumeSlider()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(25)
            .background {
                ZStack {
                    Rectangle()
                        .fill(Color(viewModel.backgroundColor).gradient)
                        .animation(.easeInOut, value: viewModel.backgroundColor)
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
                .ignoresSafeArea()
            }
            .environment(\.colorScheme, viewModel.backgroundIsLight ? .light : .dark)
        }
    }
}
