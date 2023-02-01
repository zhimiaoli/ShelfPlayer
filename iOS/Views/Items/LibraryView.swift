//
//  LibraryView.swift
//  Books
//
//  Created by Rasmus Krämer on 29.01.23.
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    @State private var sortOrder: ItemSort = .title
    
    var body: some View {
        ItemGridView(getItems: {
            try await APIClient.authorizedShared.request(APIResources.libraries(id: globalViewModel.activeLibraryId).items(sort: sortOrder)).results
        })
        .navigationTitle("Library")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(ItemSort.allCases.filter(filterCases), id: \.rawValue) { order in
                        Button {
                            sortOrder = order
                            NotificationCenter.default.post(name: NSNotification.ItemGridSortOrderUpdated, object: nil)
                        } label: {
                            if sortOrder == order {
                                Label(FilterHelper.getSortLabel(item: order), systemImage: "checkmark")
                            } else {
                                Text(FilterHelper.getSortLabel(item: order))
                            }
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                LibraryPicker()
            }
        }
        .onAppear(perform: updateSortOrder)
        .onChange(of: globalViewModel.activeLibraryId) { _ in
            updateSortOrder()
        }
        .onReceive(NSNotification.LibrarySettingsUpdated) { _ in
            updateSortOrder()
        }
    }
    
    private func updateSortOrder() {
        sortOrder = FilterHelper.getDefaultLibrarySortOrder(mediaType: globalViewModel.activeLibraryType ?? "")
        NotificationCenter.default.post(name: NSNotification.ItemGridSortOrderUpdated, object: nil)
    }
    private func filterCases(item: ItemSort) -> Bool {
        return FilterHelper.filterCases(item, libraryType: globalViewModel.activeLibraryType ?? "")
    }
}
