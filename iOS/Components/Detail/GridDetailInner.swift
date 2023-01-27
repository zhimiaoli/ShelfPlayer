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
    
    var body: some View {
        ItemGridView(getItems: {
            try await APIClient.authorizedShared.request(APIResources.libraries(id: PersistenceController.shared.getLoggedInUser()!.lastActiveLibraryId ?? "").items(filter: "\(scope).\(item.id.toBase64())")).results
        })
        .navigationTitle(item.title)
    }
}
