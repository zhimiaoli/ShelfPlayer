//
//  NowPlayingWrapepr.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

struct NowPlayingWrapper<Content: View>: View {
    @ViewBuilder var content: Content
    
    @EnvironmentObject var globalViewModel: GlobalViewModel
    @StateObject var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        #if targetEnvironment(macCatalyst)
        VStack(spacing: 0) {
            content
            
            Rectangle()
                .frame(height: 75)
        }
        #else
        ZStack(alignment: .bottom) {
            content
                .padding(.bottom, globalViewModel.showNowPlayingBar ? 65 : 0)
            
            if globalViewModel.showNowPlayingBar {
                NowPlayingBar()
                    .onTapGesture {
                        globalViewModel.nowPlayingSheetPresented.toggle()
                    }
                    .sheet(isPresented: $globalViewModel.nowPlayingSheetPresented) {
                        NowPlayingSheet()
                            .presentationDragIndicator(.visible)
                            .presentationDetents([.large])
                    }
            }
        }
        .onChange(of: globalViewModel.currentlyPlaying) { item in
            if globalViewModel.showNowPlayingBar {
                Task.detached {
                    let (backgroundColor, backgroundIsLight) = await globalViewModel.currentlyPlaying!.getAverageColor()
                    
                    DispatchQueue.main.async {
                        withAnimation {
                            viewModel.backgroundColor = backgroundColor
                            viewModel.backgroundIsLight = backgroundIsLight
                        }
                    }
                }
            }
        }
        .environmentObject(viewModel)
        #endif
    }
}

extension NowPlayingWrapper {
    class ViewModel: ObservableObject {
        @Published var backgroundColor: UIColor = .systemBackground
        @Published var backgroundIsLight: Bool = UIColor.systemBackground.isLight() ?? false
    }
}
