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
        
        @State private var slider = 0.0
        
        var body: some View {
            GeometryReader { proxy in
                VStack {
                    ItemImage(item: globalViewModel.currentlyPlaying, size: proxy.size.width)
                        .shadow(radius: 10)
                        .padding(.vertical, 10)
                    
                    if globalViewModel.currentlyPlaying!.isBook {
                        BookTitle()
                    }
                    
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
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
                .ignoresSafeArea()
            }
            .environment(\.colorScheme, viewModel.backgroundIsLight ? .light : .dark)
        }
    }
}
