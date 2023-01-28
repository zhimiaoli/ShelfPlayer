//
//  NowPlayingWrapepr.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

struct NowPlayingWrapper<Content: View>: View {
    @ViewBuilder var content: Content
    
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    @StateObject private var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .padding(.bottom, viewModel.showNowPlayingBar ? 65 : 0)
            
            if viewModel.showNowPlayingBar {
                NowPlayingBar()
                    .onTapGesture {
                        viewModel.nowPlayingSheetPresented.toggle()
                    }
                    .sheet(isPresented: $viewModel.nowPlayingSheetPresented) {
                        NowPlayingSheet()
                            .presentationDragIndicator(.visible)
                            .presentationDetents([.large])
                    }
            }
        }
        .onChange(of: globalViewModel.currentlyPlaying) { item in
            viewModel.showNowPlayingBar = item != nil
            
            if viewModel.showNowPlayingBar {
                Task {
                    viewModel.nowPlayingSheetPresented = true
                    (viewModel.backgroundColor, viewModel.backgroundIsLight) = await ImageHelper.getAverageColor(item: globalViewModel.currentlyPlaying!)
                }
            }
        }
        .environmentObject(viewModel)
    }
}

extension NowPlayingWrapper {
    class ViewModel: ObservableObject {
        @Published var showNowPlayingBar: Bool = false
        @Published var nowPlayingSheetPresented: Bool = false
        
        @Published var backgroundColor: UIColor = .systemBackground
        @Published var backgroundIsLight: Bool = UIColor.systemBackground.isLight() ?? false
    }
}
