//
//  Regular+Buttons.swift
//  Multiplatform
//
//  Created by Rasmus Krämer on 23.04.24.
//

import SwiftUI
import SPBase
import SPPlayback

extension RegularNowPlayingView {
    struct Buttons: View {
        @Binding var notableMomentsToggled: Bool
        
        @State private var notableMomentSheetPresented = false
        
        var body: some View {
            HStack(alignment: .center) {
                AirPlayView()
                    .frame(width: 35)
                
                Spacer()
                
                PlaybackSpeedButton()
                    .font(.system(size: 21))
                    .foregroundStyle(.secondary)
                
                SleepTimerButton()
                    .labelStyle(.iconOnly)
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                
                if AudioPlayer.shared.item as? Audiobook != nil {
                    Button {
                        notableMomentsToggled.toggle()
                    } label: {
                        Image(systemName: "bookmark.square")
                            .symbolVariant(notableMomentsToggled ? .fill : .none)
                    }
                    .font(.system(size: 23))
                    .foregroundStyle(.secondary)
                }
            }
            .bold()
            .font(.system(size: 20))
            .frame(height: 45)
        }
    }
}