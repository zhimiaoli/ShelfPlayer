//
//  ItemRow.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct ItemRow: View {
    var title: String?
    var content: [LibraryItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = title {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .padding(.horizontal, 4)
            }
            
            LazyHStack {
                ForEach(content, id: \.identifier) { item in
                    ItemRowItem(item: item)
                        .padding(.horizontal, 4)
                }
            }
        }
    }
}
