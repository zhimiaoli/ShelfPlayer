//
//  SettingsView.swift
//  Books
//
//  Created by Rasmus Krämer on 29.01.23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    @State var selectedFilter: EpisodeFilter = FilterHelper.defaultFilter
    @State var selectedSortOrder: EpisodeSort = FilterHelper.defaultSortOrder
    @State var sortInvert: Bool = FilterHelper.defaultInvert
    
    @State var bookDefaultSort: ItemSort = FilterHelper.getDefaultLibrarySortOrder(mediaType: "book")
    @State var podcastDefaultSort: ItemSort = FilterHelper.getDefaultLibrarySortOrder(mediaType: "podcast")
    
    @State var useChapterView: Bool = PlayerHelper.getUseChapterView()
    @State var allowDownloadsOverMobile: Bool = DownloadHelper.getAllowDownloadsOverMobile()
    
    var body: some View {
        NavigationStack {
            Form {
                // Podcast
                FilterSelector(selectedFilter: $selectedFilter, selectedSortOrder: $selectedSortOrder, sortInvert: $sortInvert)
                    .onChange(of: selectedFilter) { filter in
                        FilterHelper.setDefaultFilter(filter: filter)
                    }
                    .onChange(of: selectedSortOrder) { order in
                        FilterHelper.setDefaultSortOrder(order: order)
                    }
                    .onChange(of: sortInvert) { invert in
                        FilterHelper.setDefaultInvert(invert: invert)
                    }
                
                // Library
                Section {
                    Picker("Books", selection: $bookDefaultSort) {
                        ForEach(ItemSort.allCases.filter { FilterHelper.filterCases($0, libraryType: "book") }, id: \.hashValue) {
                            Text(FilterHelper.getSortLabel(item: $0))
                            .tag($0)
                        }
                    }
                    .onChange(of: bookDefaultSort) { order in
                        FilterHelper.setDefaultLibrarySortOrder(order: order, mediaType: "book")
                        NotificationCenter.default.post(name: NSNotification.LibrarySettingsUpdated, object: nil)
                    }
                    
                    Picker("Podcasts", selection: $podcastDefaultSort) {
                        ForEach(ItemSort.allCases.filter { FilterHelper.filterCases($0, libraryType: "podcast") }, id: \.hashValue) {
                            Text(FilterHelper.getSortLabel(item: $0))
                            .tag($0)
                        }
                    }
                    .onChange(of: podcastDefaultSort) { order in
                        FilterHelper.setDefaultLibrarySortOrder(order: order, mediaType: "podcast")
                        NotificationCenter.default.post(name: NSNotification.LibrarySettingsUpdated, object: nil)
                    }
                } header: {
                    Text("Libraries")
                } footer: {
                    Text("This filter will be applied by default")
                }
                
                Section {
                    Toggle("Show chapter track", isOn: $useChapterView)
                        .onChange(of: useChapterView, perform: { use in
                            PlayerHelper.setUseChapterView(use)
                            NotificationCenter.default.post(name: NSNotification.PlayerSettingsUpdated, object: nil)
                        })
                } header: {
                    Text("Player")
                }
                
                Section {
                    Toggle("Mobile downloads", isOn: $allowDownloadsOverMobile)
                        .onChange(of: allowDownloadsOverMobile, perform: { allow in
                            DownloadHelper.setAllowDownloadsOverMobile(allow)
                        })
                    NavigationLink(destination: Text("add me")) {
                        Text("Manage")
                    }
                } header: {
                    Text("Downloads")
                }
                
                // Account
                Section {
                    HStack {
                        Text("Account")
                        Spacer()
                        Text(PersistenceController.shared.getLoggedInUser()?.username ?? "?")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("URL")
                        Spacer()
                        Text(PersistenceController.shared.getLoggedInUser()?.serverUrl?.description ?? "?")
                            .foregroundColor(.secondary)
                    }
                    Button {
                        globalViewModel.logout()
                    } label: {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Account")
                }
                
                // Debug
                NavigationLink(destination: DebugView()) {
                    Label("Debug", systemImage: "hammer.fill")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
