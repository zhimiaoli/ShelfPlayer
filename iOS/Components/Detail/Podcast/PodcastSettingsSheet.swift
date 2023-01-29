//
//  PodcastSettingsSheet.swift
//  Books
//
//  Created by Rasmus Krämer on 29.01.23.
//

import SwiftUI

struct PodcastSettingsSheet: View {
    var item: LibraryItem
    
    init(item: LibraryItem) {
        self.item = item
        
        self.selectedFilter = FilterHelper.getDefaultFilter(podcastId: item.id)
    }
    
    @State var sheetPresented: Bool = false
    @State var selectedFilter: EpisodeFilter
    
    var body: some View {
        Button {
            sheetPresented = true
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .sheet(isPresented: $sheetPresented) {
                    NavigationStack {
                        Form {
                            Picker("Filter", selection: $selectedFilter) {
                                ForEach(EpisodeFilter.allCases, id: \.rawValue) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                        }
                        .navigationTitle(item.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                    }
                    .foregroundColor(.primary)
                    .bold(false)
                    
                    .onChange(of: selectedFilter) { filter in
                        FilterHelper.setDefaultFilter(podcastId: item.identifier, filter: filter)
                    }
                }
        }
        .ignoresSafeArea()
    }
}
