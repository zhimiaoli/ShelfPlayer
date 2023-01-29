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
    
    var body: some View {
        NavigationStack {
            Form {
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
