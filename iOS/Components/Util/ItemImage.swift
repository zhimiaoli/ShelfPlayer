//
//  ItemImage.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct ItemImage: View {
    var id: String
    var size: Int = 175
    
    private let user = PersistenceController.shared.getLoggedInUser()!
    
    var body: some View {
        AsyncImage(url: ImageHelper.getImageUrl(id: id)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else if phase.error != nil {
                Image(systemName: "book")
                    .dynamicTypeSize(.xLarge)
            } else {
                ProgressView()
            }
        }
        .cornerRadius(7)
        .frame(width: CGFloat(size), height: CGFloat(size))
        .background(Color.gray.opacity(0.1))
    }
}
