//
//  Itemgrid.swift
//  Books
//
//  Created by Rasmus Krämer on 24.01.23.
//

import SwiftUI

struct ItemGrid: View {
    var content: [LibraryItem]
    
    @State private var size: CGFloat = 0
    
    var body: some View {
        GeometryReader { reader in
            ScrollView(.vertical, showsIndicators: false) {
                if size != 0 {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(content, id: \.identifier) { item in
                            ItemRowItem(item: item, size: size, shadow: true)
                                .padding(.vertical, 5)
                        }
                    }
                }
            }
            .onAppear {
                size = (reader.size.width - 30) / 2
            }
        }
        .padding(.horizontal, 15)
    }
}
