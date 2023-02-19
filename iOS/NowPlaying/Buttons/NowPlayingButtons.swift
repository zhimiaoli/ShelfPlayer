//
//  NowPlayingButtons.swift
//  Books
//
//  Created by Rasmus Krämer on 31.01.23.
//

import SwiftUI

struct NowPlayingButtons: View {
    @State var playing: Bool = PlayerHelper.audioPlayer?.isPlaying() ?? false
    
    var body: some View {
        HStack {
            Button {
                PlayerHelper.audioPlayer?.seek(to: PlayerHelper.audioPlayer!.getCurrentTime() - Double(PlayerHelper.getBackwardsSeekDuration()))
                Haptics.shared.play(.medium)
            } label: {
                Image(systemName: "gobackward.\(PlayerHelper.getBackwardsSeekDuration())")
                    .dynamicTypeSize(.xxxLarge)
                    .scaleEffect(1.5)
            }
            
            Button {
                PlayerHelper.audioPlayer?.setPlaying(!playing, allowAdjustment: true)
                Haptics.shared.play(.heavy)
            } label: {
                if playing {
                    Image(systemName: "pause.fill")
                        .dynamicTypeSize(.xxxLarge)
                        .scaleEffect(2.4)
                } else {
                    Image(systemName: "play.fill")
                        .dynamicTypeSize(.xxxLarge)
                        .scaleEffect(2.4)
                }
            }
            .padding(.horizontal, 75)
            
            Button {
                PlayerHelper.audioPlayer?.seek(to: PlayerHelper.audioPlayer!.getCurrentTime() + Double(PlayerHelper.getForwardsSeekDuration()))
                Haptics.shared.play(.medium)
            } label: {
                Image(systemName: "goforward.\(PlayerHelper.getForwardsSeekDuration())")
                    .dynamicTypeSize(.xxxLarge)
                    .scaleEffect(1.5)
            }
        }
        .foregroundColor(.primary)
        .onReceive(NSNotification.PlayerStateChanged, perform: { _ in
            playing = PlayerHelper.audioPlayer?.isPlaying() ?? false
        })
    }
}
