//
//  EpisodeView.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 08.10.23.
//

import SwiftUI
import SPBase

struct EpisodeView: View {
    let episode: Episode
    
    @State var navigationBarVisible = false
    @State var imageColors = Item.ImageColors.placeholder
    
    var body: some View {
        ScrollView {
            Header(episode: episode, imageColors: imageColors, navigationBarVisible: $navigationBarVisible)
            Description(description: episode.description)
                .padding(20)
        }
        .ignoresSafeArea(edges: .top)
        .modifier(NowPlayingBarSafeAreaModifier())
        .modifier(ToolbarModifier(episode: episode, navigationBarVisible: navigationBarVisible, imageColors: imageColors))
        .onAppear {
            Task.detached {
                let colors = episode.getImageColors()
                
                Task { @MainActor in
                    withAnimation(.spring) {
                        self.imageColors = colors
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EpisodeView(episode: Episode.fixture)
    }
}
