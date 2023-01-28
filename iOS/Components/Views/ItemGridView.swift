//
//  ItemGrid.swift
//  Books
//
//  Created by Rasmus Krämer on 27.01.23.
//

import SwiftUI

struct ItemGridView: View {
    @State private var failed: Bool = false
    @State private var items: [LibraryItem]?
    
    let getItems: @Sendable () async throws -> [LibraryItem]?
    
    var body: some View {
        Group {
            if !failed {
                if let items = items {
                    ItemGrid(content: items)
                } else {
                    ProgressView()
                        .task(_getItems)
                }
            } else {
                Text("Error while loading items")
                    .font(.system(.caption, design: .rounded).smallCaps())
                    .foregroundColor(Color.gray)
            }
        }
    }
    
    @Sendable private func _getItems() async {
        do {
            items = try await getItems()
        } catch {
            failed = true
        }
    }
}
