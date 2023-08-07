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
    @State var deleteDownloadsWhenFinished: Bool = DownloadHelper.getDeleteDownloadsWhenFinished()
    
    var body: some View {
        NavigationView {
            Form {
                // Podcast
                FilterSelector(selectedFilter: $selectedFilter, selectedSortOrder: $selectedSortOrder, sortInvert: $sortInvert)
                    .onChange(of: selectedFilter) {
                        FilterHelper.setDefaultFilter(filter: selectedFilter)
                    }
                    .onChange(of: selectedSortOrder) {
                        FilterHelper.setDefaultSortOrder(order: selectedSortOrder)
                    }
                    .onChange(of: sortInvert) {
                        FilterHelper.setDefaultInvert(invert: sortInvert)
                    }
                
                // Library
                Section {
                    Picker("Books", selection: $bookDefaultSort) {
                        ForEach(ItemSort.allCases.filter { FilterHelper.filterCases($0, libraryType: "book") }, id: \.hashValue) {
                            Text(FilterHelper.getSortLabel(item: $0))
                                .tag($0)
                        }
                    }
                    .onChange(of: bookDefaultSort) {
                        FilterHelper.setDefaultLibrarySortOrder(order: bookDefaultSort, mediaType: "book")
                        NotificationCenter.default.post(name: NSNotification.LibrarySettingsUpdated, object: nil)
                    }
                    
                    Picker("Podcasts", selection: $podcastDefaultSort) {
                        ForEach(ItemSort.allCases.filter { FilterHelper.filterCases($0, libraryType: "podcast") }, id: \.hashValue) {
                            Text(FilterHelper.getSortLabel(item: $0))
                                .tag($0)
                        }
                    }
                    .onChange(of: podcastDefaultSort) {
                        FilterHelper.setDefaultLibrarySortOrder(order: podcastDefaultSort, mediaType: "podcast")
                        NotificationCenter.default.post(name: NSNotification.LibrarySettingsUpdated, object: nil)
                    }
                } header: {
                    Text("Libraries")
                } footer: {
                    Text("This sort order will be applied by default")
                }
                
                Section {
                    Toggle("Show chapter track", isOn: $useChapterView)
                        .onChange(of: useChapterView) {
                            PlayerHelper.setUseChapterView(useChapterView)
                            NotificationCenter.default.post(name: NSNotification.PlayerSettingsUpdated, object: nil)
                        }
                } header: {
                    Text("Player")
                }
                
                Section {
                    Toggle("Mobile downloads", isOn: $allowDownloadsOverMobile)
                        .onChange(of: allowDownloadsOverMobile) {
                            DownloadHelper.setAllowDownloadsOverMobile(allowDownloadsOverMobile)
                        }
                    Toggle("Delete downloads when finished", isOn: $deleteDownloadsWhenFinished)
                        .onChange(of: deleteDownloadsWhenFinished) {
                            DownloadHelper.setDeleteDownloadsWhenFinished(allowDownloadsOverMobile)
                        }
                    NavigationLink(destination: DownloadsManageView(detailed: false)) {
                        Text("Manage")
                    }
                    Button {
                        globalViewModel.onlineStatus = .offline
                    } label: {
                        Text("Go offline")
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
