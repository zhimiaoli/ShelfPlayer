//
//  GenreView.swift
//  Books
//
//  Created by Rasmus Krämer on 29.01.23.
//

import SwiftUI

struct GenreView: View {
    let genre: String
    
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    var body: some View {
        ItemGridView(getItems: {
            try await APIClient.authorizedShared.request(APIResources.libraries(id: globalViewModel.activeLibraryId).items(filter: "genres.\(genre.toBase64())")).results
        })
        .navigationTitle(genre)
    }
}
