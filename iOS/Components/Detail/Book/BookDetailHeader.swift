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
        @EnvironmentObject private var viewModel: BookDetailViewModel
        
        var body: some View {
            VStack {
                ItemImage(item: viewModel.item, size: 300)
                    .shadow(radius: 10)
                    .onBecomingVisible {
                        if !viewModel.animateNavigationBarChanges {
                            viewModel.isNavigationBarVisible = false
                            return
                        }
                        
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.isNavigationBarVisible = false
                        }
                    }
                    .onBecomingInvisible {
                        if !viewModel.animateNavigationBarChanges {
                            viewModel.isNavigationBarVisible = true
                            return
                        }
                        
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.isNavigationBarVisible = true
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            viewModel.animateNavigationBarChanges = true
                        }
                    }
                
                VStack {
                    Text(viewModel.item.title)
                        .font(.system(.headline, design: .serif))
                    if let author = viewModel.item.media?.metadata.authorName {
                        Text(author)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Button {
                            
                        } label: {
                            Label("Listen now", systemImage: "play.fill")
                        }
                        .buttonStyle(PlayNowButtonStyle(colorScheme: viewModel.backgroundIsLight ? .dark : .light))
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "arrow.down")
                        }
                        Button {
                            
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .padding()
                .buttonStyle(SecondaryButtonStyle(colorScheme: viewModel.backgroundIsLight ? .dark : .light))
                .foregroundColor(viewModel.backgroundIsLight ? .black : .white)
                .animation(.easeInOut, value: viewModel.backgroundIsLight)
            }
            .padding(.top, 100)
            .frame(maxWidth: .infinity, alignment: .top)
            .background(Color(viewModel.backgroundColor))
            .animation(.easeInOut, value: viewModel.backgroundColor)
        }
    }
}
