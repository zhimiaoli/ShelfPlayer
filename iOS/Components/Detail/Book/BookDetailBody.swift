//
//  BookDetailBody.swift
//  Books
//
//  Created by Rasmus Krämer on 27.01.23.
//

import SwiftUI

extension DetailView {
    /// Main detail content view for books
    struct BookDetailBody: View {
        @EnvironmentObject private var viewModel: BookDetailViewModel
        
        var body: some View {
            VStack {
                VStack(alignment: .leading) {
                    if let description = viewModel.item.media?.metadata.description {
                        Text("Description")
                            .font(.system(.headline, design: .serif))
                            .padding(.bottom, 7)
                        Text(description)
                        
                        Divider()
                            .padding(.vertical, 20)
                    }
                    
                    BookDetailGrid()
                    
                    Divider()
                        .padding(.vertical, 20)
                }
                .padding(.horizontal)
                .padding(.top)
                
                BookDetailSeries()
            }
        }
    }
}
