//
//  OfflineItemImage.swift
//  Books
//
//  Created by Rasmus Krämer on 05.02.23.
//

import SwiftUI

struct OfflineItemImage: View {
    var url: URL!
    var size: CGFloat? = 175
    
    var body: some View {
        Group {
            AsyncImage(url: url) { phase in
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
        }
        .frame(width: size, height: size)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(7)
    }
}
