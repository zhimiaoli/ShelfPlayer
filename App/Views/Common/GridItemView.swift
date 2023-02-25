//
//  ItemGrid.swift
//  Books
//
//  Created by Rasmus Krämer on 27.01.23.
//

import SwiftUI

struct ItemGridView: View {
    let getItems: @Sendable () async throws -> [LibraryItem]?
    
    @State var failed: Bool = false
    @State var items: [LibraryItem]?
    
    var body: some View {
        Group {
            if !failed {
                if let items = items {
                    ItemGrid(content: items)
                } else {
                    ProgressView()
                        .onAppear {
                            Task.detached {
                                await  _getItems()
                            }
                        }
                }
            } else {
                Text("Error while loading items")
                    .font(.system(.caption, design: .rounded).smallCaps())
                    .foregroundColor(Color.gray)
            }
        }.onReceive(NSNotification.ItemGridSortOrderUpdated) { _ in
            Task.detached {
                await _getItems()
            }
        }
    }
    
    @Sendable private func _getItems() async {
        do {
            items = try await getItems()
            failed = false
        } catch {
            print(error)
            failed = true
        }
    }
}
