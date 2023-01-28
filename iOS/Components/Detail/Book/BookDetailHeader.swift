//
//  BookDetailHeader.swift
//  Books
//
//  Created by Rasmus Krämer on 27.01.23.
//

import SwiftUI

extension DetailView {
    /// Header for books containing the title, author and image of the item
    struct BookDetailHeader: View {
        @EnvironmentObject private var viewModel: ViewModel
        @EnvironmentObject private var globalViewModel: GlobalViewModel
        @EnvironmentObject private var fullscreenViewModel: FullscrenViewViewModel
        
        var body: some View {
            VStack {
                ItemImage(item: viewModel.item, size: 300)
                    .shadow(radius: 10)
                    .onBecomingVisible {
                        fullscreenViewModel.hideNavigationBar()
                    }
                    .onBecomingInvisible {
                        fullscreenViewModel.showNavigationBar()
                    }
                
                VStack {
                    Text(viewModel.item.title)
                        .font(.system(.headline, design: .serif))
                    Text(viewModel.item.author)
                        .font(.subheadline)
                    
                    ItemButtons(item: viewModel.item, colorScheme: viewModel.backgroundIsLight ? .dark : .light)
                }
                .padding()
                .foregroundColor(viewModel.backgroundIsLight ? .black : .white)
                .animation(.easeInOut, value: viewModel.backgroundIsLight)
            }
            .padding(.top, 100)
            .frame(maxWidth: .infinity, alignment: .top)
            .background(Color(fullscreenViewModel.backgroundColor))
            .animation(.easeInOut, value: fullscreenViewModel.backgroundColor)
        }
    }
}
