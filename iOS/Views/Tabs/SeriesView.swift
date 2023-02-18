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
    @State var sortOrder: SeriesSort = .name
    
    var body: some View {
        ItemGridView(getItems: {
            try await APIClient.authorizedShared.request(APIResources.libraries(id: globalViewModel.activeLibraryId).series(sort: sortOrder)).results
        })
        .navigationTitle("Series")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(SeriesSort.allCases, id: \.rawValue) { order in
                        Button {
                            sortOrder = order
                            NotificationCenter.default.post(name: NSNotification.ItemGridSortOrderUpdated, object: nil)
                        } label: {
                            if sortOrder == order {
                                Label(getLabel(order), systemImage: "checkmark")
                            } else {
                                Text(getLabel(order))
                            }
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
    
    private func getLabel(_ order: SeriesSort) -> String {
        var title: String = ""
        
        switch order {
        case .name:
            title = "Title"
        case .numBooks:
            title = "Book count"
        case .totalDuration:
            title = "Total duration"
        case .addedAt:
            title = "Added at"
        }
        
        return title
    }
}
