//
//  Itemgrid.swift
//  Books
//
//  Created by Rasmus Krämer on 24.01.23.
//

import SwiftUI

struct ItemGrid: View {
    var content: [LibraryItem]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ForEach(content) { item in
                ItemRowItem(item: item)
                    .padding(.horizontal, 4)
            }
        }
    }
}
