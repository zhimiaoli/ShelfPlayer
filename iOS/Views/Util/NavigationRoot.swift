//
//  NavigationRoot.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

/// Main navigation controller. Only used when the user is logged in and online
struct NavigationRoot: View {
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
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
            
            // switch is way to complicated
            if globalViewModel.activeLibraryType == "book" {
                NowPlayingWrapper {
                    Text("series")
                }
                .tabItem {
                    Label("Series", systemImage: "books.vertical.circle.fill")
                }
            }
            
            NowPlayingWrapper {
                Text("library")
            }
            .tabItem {
                Label("Library", systemImage: "bookmark.square.fill")
            }
            
            NowPlayingWrapper {
                Text("search")
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass.circle.fill")
            }
        }
        .sheet(isPresented: $globalViewModel.settingsSheetPresented) {
            SettingsView()
        }
    }
}
