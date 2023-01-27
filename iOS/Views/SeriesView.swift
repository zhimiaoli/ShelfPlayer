//
//  SeriesView.swift
//  Books
//
//  Created by Rasmus Krämer on 27.01.23.
//

import SwiftUI

struct SeriesView: View {
    @State var sortOrder: ItemSortOrder = .name
    
    var body: some View {
        ItemGridView(getItems: {
            try await APIClient.authorizedShared.request(APIResources.libraries(id: PersistenceController.shared.getLoggedInUser()!.lastActiveLibraryId ?? "").series(sort: sortOrder)).results
        })
        .navigationTitle("Series")
        /*
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(ItemSortOrder.allCases, id: \.rawValue) { order in
                        Button {
                            sortOrder = order
                        } label: {
                            Text(order.rawValue)
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
         */
    }
}
