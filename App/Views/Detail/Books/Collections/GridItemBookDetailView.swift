//
//  ItemDetailGridItem.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import SwiftUI

extension DetailView {
    /// Small piece of information regarding a item
    struct ItemDetailGridItem: View {
        var title: String
        var summary: String
        var description: String
        
        var body: some View {
            VStack() {
                Text("\(title.uppercased())")
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                Text("\(summary)")
                    .font(.title2)
                    .fontDesign(.serif)
                Text("\(description)")
                    .font(.caption)
            }
            .foregroundColor(.primary)
            .padding()
            .frame(maxWidth: 200)
        }
    }
}
