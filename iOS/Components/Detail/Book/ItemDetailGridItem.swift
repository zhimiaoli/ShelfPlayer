//
//  ItemDetailGridItem.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import SwiftUI

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
                .font(.system(.title2, design: .serif))
            Text("\(description)")
                .font(.caption)
        }
        .foregroundColor(.primary)
        .padding()
        .frame(maxWidth: 200)
    }
}

struct ItemDetailGridItem_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailGridItem(title: "Test", summary: "TE", description: "A test")
    }
}
