//
//  SeriesView.swift
//  Books
//
//  Created by Rasmus Krämer on 27.01.23.
//

import SwiftUI

/// View containing all series of the last active library
struct SeriesView: View {
    @EnvironmentObject var globalViewModel: GlobalViewModel
    @State var sortOrder: ItemSortOrder = .name
    
    var body: some View {
        ItemGridView(getItems: {
            try await APIClient.authorizedShared.request(APIResources.libraries(id: globalViewModel.activeLibraryId).series(sort: sortOrder)).results
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
