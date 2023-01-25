//
//  ItemRowItem.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct ItemRowItem: View {
    var item: LibraryItem
    var size: CGFloat?
    
    @State private var progressPercentage: Float = 0
    @State private var actualSize: CGFloat = 175
    
    @Environment(\.itemRowItemWidth) private var enviromentSize
    
    var body: some View {
        NavigationLink(destination: DetailView(item: item)) {
            VStack(alignment: .leading) {
                ItemImage(url: item.cover, size: actualSize)
                
                HStack {
                    Text(verbatim: item.title)
                        .font(.system(.caption, design: .serif))
                        .bold()
                        .tint(.primary)
                    Spacer()
                    
                    if progressPercentage > 0 {
                        if progressPercentage >= 1 {
                            Text("100%")
                                .font(.system(.caption, design: .rounded).smallCaps())
                                .foregroundColor(Color.gray)
                        } else {
                            ProgressIndicator(completedPercentage: progressPercentage)
                        }
                    } else if let numBooks = item.numBooks {
                        Text(String(numBooks))
                            .font(.system(.caption, design: .rounded).smallCaps())
                            .foregroundColor(Color.gray)
                    }
                }
                .frame(height: 15)
            }
            .frame(width: actualSize)
            .onAppear {
                progressPercentage = PersistenceController.shared.getProgressByLibraryItemId(id: item.id)
            }
        }
        .onAppear {
            // actualSize = size ?? enviromentSize.wrappedValue
        }
    }
}
