//
//  ItemRowItem.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct ItemRowItem: View {
    @State private var progressPercentage: Float = 0
    var item: LibraryItem
    
    var body: some View {
        NavigationLink(destination: DetailView(item: item)) {
            VStack(alignment: .leading) {
                ItemImage(id: item.id)
                
                HStack {
                    Text(verbatim: item.media?.metadata.title ?? "unknown title")
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
                    }
                }
                .frame(height: 15)
            }
            .frame(width: 175)
            .onAppear {
                progressPercentage = PersistenceController.shared.getProgressByLibraryItemId(id: item.id)
            }
        }
    }
}
