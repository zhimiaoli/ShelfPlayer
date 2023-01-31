//
//  FullscreenView.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

struct FullscreenView<Content: View, Menu: View>: View {
    var presentationMode: Binding<PresentationMode>
    @ViewBuilder var content: Content
    @ViewBuilder var menu: Menu
    
    @StateObject var viewModel: FullscrenViewViewModel = FullscrenViewViewModel()
    
    var body: some View {
        GeometryReader { reader in
            ScrollView(showsIndicators: false) {
                VStack() {
                    content
                }.background(
                    GeometryReader { proxy -> Color in
                        DispatchQueue.main.async {
                            let offset = -proxy.frame(in: .named("scroll")).origin.y - 59
                            viewModel.changeScrollViewBackground = offset < 0
                        }
                        return Color(uiColor: UIColor.systemBackground)
                    })
            }
            // Navigation bar
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            
            // Toolbar
            .toolbar(viewModel.isNavigationBarVisible ? .visible : .hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    menu
                        .fontWeight(.bold)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                }
            }
            .overlay(alignment: .topLeading) {
                HStack {
                    if presentationMode.wrappedValue.isPresented {
                        // A button does not work here
                        Image(systemName: "chevron.left.circle.fill")
                            .onTapGesture {
                                withAnimation {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            .offset(y: 60)
                            .ignoresSafeArea()
                    }
                    
                    Spacer()
                    
                    HStack {
                        menu
                    }
                    .offset(y: 60)
                    .ignoresSafeArea()
                }
                .fontWeight(.bold)
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.accentColor)
                .dynamicTypeSize(.xxxLarge)
                .padding(.horizontal, 20)
                .animation(.easeInOut, value: viewModel.isNavigationBarVisible)
                .opacity(viewModel.isNavigationBarVisible ? 0 : 1)
            }
            .modifier(GestureSwipeRight(action: {
                if presentationMode.wrappedValue.isPresented && !viewModel.isNavigationBarVisible {
                    withAnimation {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }))
            
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
    @Published var isNavigationBarVisible: Bool = false
    @Published var animateNavigationBarChanges: Bool = false
    
    @Published var changeScrollViewBackground: Bool = false
    @Published var mainContentMinHeight: CGFloat = 400
    
    @Published var backgroundColor = UIColor.secondarySystemBackground
    
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

struct FullscreenView_Previews: PreviewProvider {
    @Environment(\.presentationMode) private static var presentationMode: Binding<PresentationMode>
    
    static var previews: some View {
        FullscreenView(presentationMode: presentationMode) {
            Text("This is not usefull at all")
        } menu: {
            
        }
    }
}
