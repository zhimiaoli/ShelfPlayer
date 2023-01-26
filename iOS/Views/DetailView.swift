//
//  DetailView.swift
//  Books
//
//  Created by Rasmus Krämer on 25.11.22.
//

import SwiftUI

struct DetailView: View {
    var id: String?
    var item: LibraryItem?
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        if let item = item {
            if item.isBook {
                BookDetailInner(item: item, presentationMode: presentationMode)
            } else if item.isSeries {
                GridDetailInner(item: item, scope: "series")
            } else if item.isAuthor {
                GridDetailInner(item: item, scope: "authors")
            }
        } else {
            if id == nil {
                Text("Error")
                    .bold()
                    .foregroundColor(Color.red)
            } else {
                FullscreenLoadingIndicator(description: "Loading")
            }
        }
    }
}
