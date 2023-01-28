//
//  NavigationRoot.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

/// Main navigation controller. Only used when the user is logged in and online
struct NavigationRoot: View {
    var body: some View {
        TabView {
            NowPlayingWrapper {
                NavigationView {
                    HomeView()
                }
            }
            .tabItem {
                Label("Listen now", systemImage: "book.circle.fill")
            }
            
            DebugView()
            .tabItem {
                Label("Debug", systemImage: "gear.circle.fill")
            }
        }
    }
}

struct NavigationRoot_Previews: PreviewProvider {
    static var previews: some View {
        NavigationRoot()
    }
}
