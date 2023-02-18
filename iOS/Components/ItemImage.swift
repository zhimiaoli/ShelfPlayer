//
//  ItemImage.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct ItemImage: View {
    var item: LibraryItem?
    var size: CGFloat? = 175
    
    var fallback: some View {
        Image(systemName: "book")
            .dynamicTypeSize(.xLarge)
    }
    
    var body: some View {
        Group {
            if let item = item {
                if item.cover == nil {
                    fallback
                } else {
                    AsyncImage(url: item.cover) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else if phase.error != nil {
                            fallback
                        } else {
                            ProgressView()
                        }
                    }
                }
            } else {
                fallback
            }
        }
        .frame(width: size, height: size)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(item?.isAuthor ?? false ? 100 : 7)
    }
}
