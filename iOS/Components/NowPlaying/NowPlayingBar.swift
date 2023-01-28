//
//  NowPlayingBar.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI
import MarqueeText

extension NowPlayingWrapper {
    struct NowPlayingBar: View {
        @EnvironmentObject private var globalViewModel: GlobalViewModel
        
        var body: some View {
            HStack(alignment: .center) {
                ItemImage(item: globalViewModel.currentlyPlaying, size: 55)
                    .shadow(radius: 2)
                VStack(alignment: .leading) {
                    MarqueeText(text: globalViewModel.currentlyPlaying!.title, font: UIFont.boldSystemFont(ofSize: 16), leftFade: 4, rightFade: 16, startDelay: 3)
                    MarqueeText(text: globalViewModel.currentlyPlaying!.author, font: UIFont.systemFont(ofSize: 14), leftFade: 16, rightFade: 16, startDelay: 3)
                        .foregroundColor(.gray)
                        .padding(.top, -4)
                }
                
                Spacer()
                
                Group {
                    if globalViewModel.currentlyPlaying!.isBook {
                        Button {
                            // TODO: go forwards
                        } label: {
                            Image(systemName: "gobackward.30")
                        }
                    }
                    Button {
                        // TODO: play / pause the player
                    } label: {
                        Image(systemName: "play.fill")
                    }
                    .padding(.horizontal, 5)
                    // TODO: display when item is podcast
                    if globalViewModel.currentlyPlaying!.isPodcast {
                        Button {
                            // TODO: go forwards
                        } label: {
                            Image(systemName: "goforward.30")
                        }
                    }
                }
                .dynamicTypeSize(.xxxLarge)
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 65)
            .background(.regularMaterial)
        }
    }
}
