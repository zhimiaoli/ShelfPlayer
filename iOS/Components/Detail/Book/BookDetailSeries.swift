//
//  BookDetailSeries.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import SwiftUI

struct BookDetailSeries: View {
    var name: String
    var library: String

    @State private var failed: Bool = false
    @State private var items: [LibraryItem]?
    
    var body: some View {
        if !failed {
            if let items = items {
                ItemRowContainer(title: "Also in series") {
                    ItemRow(content: items)
                }
            } else {
                ProgressView()
                    .task(getSeriesItems)
            }
        }
    }
    
    @Sendable private func getSeriesItems() async {
        do {
            let searchSeries = try await APIClient.authorizedShared.request(APIResources.series.seriesByName(search: name)).results
            if searchSeries.count == 0 {
                return failed = true
            }
            
            let seriesId = searchSeries[0].id
            items = try await APIClient.authorizedShared.request(APIResources.libraries(id: library).items(filter: "series.\(seriesId.toBase64())")).results
        } catch {
            failed = true
        }
    }
}
