//
//  GridDetailInner.swift
//  Books
//
//  Created by Rasmus Krämer on 26.01.23.
//

import SwiftUI

struct GridDetailInner: View {
    var item: LibraryItem
    var scope: String

    @State private var failed: Bool = false
    @State private var items: [LibraryItem]?
    
    var body: some View {
        Group {
            if !failed {
                if let items = items {
                    ItemGrid(content: items)
                } else {
                    ProgressView()
                        .task(getSeriesItems)
                }
            } else {
                Text("Error while loading items")
                    .font(.system(.caption, design: .rounded).smallCaps())
                    .foregroundColor(Color.gray)
            }
        }
        .navigationTitle(item.title)
    }
    
    @Sendable private func getSeriesItems() async {
        do {
            items = try await APIClient.authorizedShared.request(APIResources.libraries(id: PersistenceController.shared.getLoggedInUser()!.lastActiveLibraryId ?? "").items(filter: "\(scope).\(item.id.toBase64())")).results
        } catch {
            print(error)
            failed = true
        }
    }
}
