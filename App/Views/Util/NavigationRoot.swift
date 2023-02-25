//
//  NavigationRoot.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

/// Main navigation controller. Only used when the user is logged in and online
struct NavigationRoot: View {
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    @State var selectedTab: Tab? = .home
    @State var genres = [String]()
    @State var genre: String = ""
    
    var body: some View {
        // This is so stupid... You CANNOT check for iPads here
        #if os(iOS) && !targetEnvironment(macCatalyst)
        TabView {
            NowPlayingWrapper {
                NavigationStack {
                    HomeView()
                }
            }
            .tabItem {
                Label("Listen now", systemImage: "book.circle.fill")
            }
            
            // switch is way to complicated
            if globalViewModel.activeLibraryType == "book" {
                NowPlayingWrapper {
                    NavigationStack {
                        SeriesView()
                    }
                }
                .tabItem {
                    Label("Series", systemImage: "books.vertical.circle.fill")
                }
            }
            
            NowPlayingWrapper {
                NavigationStack {
                    LibraryView()
                }
            }
            .tabItem {
                Label("Library", systemImage: "bookmark.square.fill")
            }
            
            NowPlayingWrapper {
                NavigationStack {
                    SearchView()
                }
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass.circle.fill")
            }
        }
        .sheet(isPresented: $globalViewModel.settingsSheetPresented) {
            SettingsView()
        }
        #else
        NavigationSplitView(sidebar: {
            List(selection: $selectedTab) {
                NavigationLink(value: Tab.home) {
                    Label("Listen now", systemImage: "book")
                }
                if globalViewModel.activeLibraryType == "book" {
                    NavigationLink(value: Tab.series) {
                        Label("Series", systemImage: "books.vertical")
                    }
                }
                NavigationLink(value: Tab.library) {
                    Label("Library", systemImage: "bookmark")
                }
                NavigationLink(value: Tab.search) {
                    Label("Search", systemImage: "magnifyingglass")
                }
                
                Section("Genres") {
                    if genres.count == 0 {
                        Text("Loading...")
                            .disabled(true)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(genres, id: \.hashValue) { genre in
                            Text(genre)
                                .onTapGesture {
                                    self.genre = genre
                                    selectedTab = .genre
                                }
                        }
                    }
                }
            }
        }, detail: {
            NowPlayingWrapper {
                NavigationStack {
                    switch(selectedTab) {
                    case .series:
                        SeriesView()
                    case .library:
                        LibraryView()
                    case .genre:
                        GenreView(genre: genre)
                            .id(genre)
                    case .search:
                        SearchView()
                    default:
                        HomeView()
                    }
                }
            }
        })
        .onAppear(perform: getGenres)
        .onChange(of: globalViewModel.activeLibraryId, perform: { _ in getGenres() })
        #endif
    }
    
    enum Tab: Hashable {
        case home
        case series
        case library
        case genre
        case search
    }
    
    private func getGenres() {
        Task.detached {
            let genres = (try? await APIClient.authorizedShared.request(APIResources.genres.all).genres) ?? []
            print(genres)
            
            DispatchQueue.main.async {
                self.genres = genres
            }
        }
    }
}
