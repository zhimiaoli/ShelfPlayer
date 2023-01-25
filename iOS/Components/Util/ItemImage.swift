//
//  ItemImage.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct ItemImage: View {
    var url: URL?
    var size: CGFloat? = 175
    
    private let user = PersistenceController.shared.getLoggedInUser()!
    
    var fallback: some View {
        Image(systemName: "book")
            .dynamicTypeSize(.xLarge)
    }
    
    var body: some View {
        Group {
            if url == nil {
                fallback
            } else {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        let _ = print(phase.error)
                        
                        fallback
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(7)
    }
}
