//
//  BookTitle.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI
import MarqueeText

extension NowPlayingWrapper {
    struct BookTitle: View {
        @EnvironmentObject private var viewModel: ViewModel
        @EnvironmentObject private var globalViewModel: GlobalViewModel
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text("Chapter 10")
                        .font(.system(size: 21, weight: .bold, design: .serif))
                        .foregroundColor((viewModel.backgroundIsLight ? Color.black : Color.white))
                    MarqueeText(text: "\(globalViewModel.currentlyPlaying!.title) • \(globalViewModel.currentlyPlaying!.author)", font: .boldSystemFont(ofSize: 21), leftFade: 5, rightFade: 16, startDelay: 3)
                        .padding(.top, -12)
                        .foregroundColor((viewModel.backgroundIsLight ? Color.black : Color.white).opacity(0.7))
                }
                
                Spacer()
            }
        }
    }
}
