//
//  SearchView.swift
//  Books
//
//  Created by Rasmus Krämer on 01.02.23.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    @State private var query: String = ""
    
    var body: some View {
        ItemGridView(getItems: {
            let response = try await APIClient.authorizedShared.request(APIResources.libraries(id: globalViewModel.activeLibraryId).search(query: query))
            var items = [LibraryItem]()
            
            items.append(contentsOf: response.book?.map { item in item.libraryItem } ?? [])
            items.append(contentsOf: response.podcast?.map { item in item.libraryItem } ?? [])
            items.append(contentsOf: response.authors)
            items.append(contentsOf: response.series.map({ item in item.series }))
            
            return items
        })
        .navigationTitle("Search")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                LibraryPicker()
            }
        }
        .searchable(text: $query)
        .onAppear(perform: {
            NotificationCenter.default.post(name: NSNotification.ItemGridSortOrderUpdated, object: nil)
        })
        .onChange(of: globalViewModel.activeLibraryId) { _ in
            NotificationCenter.default.post(name: NSNotification.ItemGridSortOrderUpdated, object: nil)
        }
        .onChange(of: query) { _ in
            NotificationCenter.default.post(name: NSNotification.ItemGridSortOrderUpdated, object: nil)
        }
    }
}
