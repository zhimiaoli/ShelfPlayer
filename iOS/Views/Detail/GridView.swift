//
//  GridDetailInner.swift
//  Books
//
//  Created by Rasmus Krämer on 26.01.23.
//

import SwiftUI

struct GridDetailInner: View {
    let item: LibraryItem
    let scope: String
    
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    var body: some View {
        ItemGridView(getItems: {
            try await APIClient.authorizedShared.request(APIResources.libraries(id: globalViewModel.activeLibraryId).items(filter: "\(scope).\(item.identifier.toBase64())")).results
        })
        .navigationTitle(item.title)
    }
}
