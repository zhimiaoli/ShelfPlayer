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
        (self.selectedSortOrder, self.sortInvert) = FilterHelper.getDefaultSortOrder(podcastId: item.id)
        
        self.useBackgroundImage = item.getUseBackgroundImage()
    }
    
    @State var sheetPresented: Bool = false
    
    @State var selectedFilter: EpisodeFilter
    @State var selectedSortOrder: EpisodeSort
    @State var sortInvert: Bool
    
    @State var useBackgroundImage: Bool
    
    var body: some View {
        Button {
            sheetPresented = true
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .sheet(isPresented: $sheetPresented) {
                    NavigationView {
                        Form {
                            FilterSelector(selectedFilter: $selectedFilter, selectedSortOrder: $selectedSortOrder, sortInvert: $sortInvert)
                                .onChange(of: selectedFilter) { filter in
                                    FilterHelper.setDefaultFilter(podcastId: item.identifier, filter: filter)
                                    broadcastUpdate()
                                }
                                .onChange(of: selectedSortOrder) { order in
                                    FilterHelper.setDefaultSortOrder(podcastId: item.identifier, order: order, invert: sortInvert)
                                    broadcastUpdate()
                                }
                                .onChange(of: sortInvert) { invert in
                                    FilterHelper.setDefaultSortOrder(podcastId: item.identifier, order: selectedSortOrder, invert: invert)
                                    broadcastUpdate()
                                }
                            
                            Toggle("Background image", isOn: $useBackgroundImage)
                                .onChange(of: useBackgroundImage) { use in
                                    item.setUseBackgroundImage(use)
                                    broadcastUpdate()
                                }
                        }
                        .navigationTitle(item.title)
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    // Needed because this view originates from the custom tabbar
                    .foregroundColor(.none)
                    .bold(false)
                }
        }
        .ignoresSafeArea()
    }
    
    private func broadcastUpdate() {
        NotificationCenter.default.post(name: NSNotification.PodcastSettingsUpdated, object: nil)
    }
}
