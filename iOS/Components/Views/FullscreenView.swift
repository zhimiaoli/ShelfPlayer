//
//  FullscreenView.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

struct FullscreenView<Content: View, Menu: View>: View {
    @StateObject var viewModel: FullscrenViewViewModel
    
    @ViewBuilder var content: Content
    @ViewBuilder var menu: Menu
    
    var body: some View {
        GeometryReader { reader in
            ScrollView(showsIndicators: false) {
                VStack() {
                    content
                }.background(
                    GeometryReader { proxy -> Color in
                        let offset = -proxy.frame(in: .named("scroll")).origin.y - 59
                        
                        DispatchQueue.main.async {
                            if viewModel.changeScrollViewBackground && offset > 0 {
                                viewModel.changeScrollViewBackground = false
                            } else if !viewModel.changeScrollViewBackground && offset < 0 {
                                viewModel.changeScrollViewBackground = true
                            }
                        }
                        return Color(uiColor: UIColor.systemBackground)
                    })
            }
            // Navigation bar
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.isNavigationBarVisible ? viewModel.title : !viewModel.animateNavigationBarChanges ? "_______________________________" : "")
            
            // Toolbar
            .toolbarBackground(viewModel.isNavigationBarVisible ? .visible : .hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    menu
                }
            }
            
            // Background color
            .coordinateSpace(name: "scroll")
            .background(viewModel.changeScrollViewBackground ? Color(viewModel.backgroundColor) : Color.clear)
            .animation(.easeInOut, value: viewModel.backgroundColor)
            
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    viewModel.animateNavigationBarChanges = true
                }
                
                viewModel.mainContentMinHeight = reader.size.height - 300
            }
        }
        .environmentObject(viewModel)
    }
}

class FullscrenViewViewModel: ObservableObject {
    @Published var title: String
    
    @Published var isNavigationBarVisible: Bool = false
    @Published var animateNavigationBarChanges: Bool = false
    
    @Published var changeScrollViewBackground: Bool = false
    @Published var mainContentMinHeight: CGFloat = 400
    
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
