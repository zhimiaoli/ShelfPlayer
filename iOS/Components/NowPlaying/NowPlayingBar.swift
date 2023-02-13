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
        
        @State private var playing: Bool = PlayerHelper.audioPlayer?.isPlaying() ?? false
        
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
                            PlayerHelper.audioPlayer?.seek(to: PlayerHelper.audioPlayer!.getCurrentTime() - Double(PlayerHelper.getBackwardsSeekDuration()))
                        } label: {
                            Image(systemName: "gobackward.\(PlayerHelper.getBackwardsSeekDuration())")
                        }
                    }
                    Button {
                        PlayerHelper.audioPlayer?.setPlaying(!(PlayerHelper.audioPlayer?.isPlaying() ?? false))
                    } label: {
                        if playing {
                            Image(systemName: "pause.fill")
                        } else {
                            Image(systemName: "play.fill")
                        }
                    }
                    .padding(.horizontal, 10)
                    if globalViewModel.currentlyPlaying!.isPodcast {
                        Button {
                            PlayerHelper.audioPlayer?.seek(to: PlayerHelper.audioPlayer!.getCurrentTime() + Double(PlayerHelper.getBackwardsSeekDuration()))
                        } label: {
                            Image(systemName: "goforward.\(PlayerHelper.getBackwardsSeekDuration())")
                        }
                    }
                }
                .dynamicTypeSize(.xxxLarge)
            }
            .padding(.leading, 10)
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 65)
            .background(.regularMaterial)
            .toolbarBackground(.regularMaterial, for: ToolbarPlacement.tabBar)
            .onReceive(NSNotification.PlayerStateChanged, perform: { _ in
                playing = PlayerHelper.audioPlayer?.isPlaying() ?? false
            })
            .contextMenu {
                Text("Hello")
                Text("i have no idea what i should put here")
            }
        }
    }
}
