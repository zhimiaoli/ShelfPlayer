//
//  FullscreenView.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

/// Reworked using native apis. Its pretty bad now. Thanks apple
struct FullscreenView<Header: View, Content: View, Background: View>: View {
    var header: Header
    var content: Content
    var background: Background
    var menu: Menu?
    
    init(header: () -> Header, content: () -> Content, background: () -> Background, menu: (() -> Menu)? = nil) {
        self.header = header()
        self.content = content()
        self.background = background()
        self.menu = menu?()
    }
    
    typealias Menu = AnyView
    @EnvironmentObject var viewModel: FullscrenViewViewModel
    
    var body: some View {
        GeometryReader { reader in
            ScrollView(showsIndicators: false) {
                VStack() {
                    header
                        .frame(maxWidth: .infinity, alignment: .center)
                        .animation(.easeInOut, value: viewModel.backgroundColor)
                        .background {
                            GeometryReader { proxy in
                                let height = proxy.size.height
                                let minY = proxy.frame(in: .global).minY
                                
                                background
                                    .animation(.easeInOut, value: viewModel.backgroundColor)
                                    .offset(y: -minY)
                                    .frame(width: proxy.size.width, height: height + (abs(minY) < height ? minY : -height))
                                    .onChange(of: proxy.frame(in: .global)) { _ in
                                        if height + minY < 175 {
                                            viewModel.showNavigationBar()
                                        } else if abs(minY) > 0 && !viewModel.navigationBarHasBeenHidden {
                                            viewModel.navigationBarHasBeenHidden = true
                                            viewModel.showNavigationBar()
                                            
                                            // This is required because whoever implemented the toolbarBackground modifier did a terrible job. It
                                            // A) it requires the programm to wait for a few millis before working (here at least) and
                                            // B) ignores .hidden when the user scrolls down for the first time...
                                            // WHY?
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                                viewModel.hideNavigationBar()
                                            }
                                        } else {
                                            viewModel.hideNavigationBar()
                                        }
                                    }
                                    .onAppear {
                                        viewModel.mainContentMinHeight = reader.size.height - proxy.size.height
                                    }
                            }
                        }
                    
                    content
                        .frame(maxWidth: .infinity, minHeight: viewModel.mainContentMinHeight, alignment: .top)
                        .background(Color(UIColor.systemBackground))
                        .padding(.top, -10)
                }
            }
            // Toolbar
            .toolbar {
                if let menu = menu {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        menu
                    }
                }
            }
            .toolbarBackground(viewModel.isNavigationBarVisible ? .visible : .hidden, for: .navigationBar)
            
            // Navigation bar
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.isNavigationBarVisible ? viewModel.title : !viewModel.animateNavigationBarChanges ? "________________________________" : "")
            
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    viewModel.animateNavigationBarChanges = true
                }
            }
        }
    }
}

class FullscrenViewViewModel: ObservableObject {
    @Published var title: String
    
    @Published var isNavigationBarVisible: Bool = false
    @Published var animateNavigationBarChanges: Bool = false
    
    @Published var mainContentMinHeight: CGFloat = 400
    @Published var navigationBarHasBeenHidden: Bool = false
    
    @Published var backgroundColor = UIColor.secondarySystemBackground
    
    init(title: String) {
        self.title = title
    }
    
    /// Tells the FullscreenView to display the navigation bar
    public func showNavigationBar() {
        if !animateNavigationBarChanges {
            isNavigationBarVisible = true
            return
        }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            isNavigationBarVisible = true
        }
    }
    
    /// Tells the FullscreenView to hide the navigation bar
    public func hideNavigationBar() {
        if !animateNavigationBarChanges {
            isNavigationBarVisible = false
            return
        }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            isNavigationBarVisible = false
        }
    }
}
