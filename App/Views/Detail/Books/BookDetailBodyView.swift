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
        @EnvironmentObject var globalViewModel: GlobalViewModel
        @EnvironmentObject var viewModel: ViewModel
        
        var body: some View {
            VStack {
                VStack(alignment: .leading) {
                    if let description = viewModel.item.media?.metadata.description {
                        Text("Description")
                            .font(.headline)
                            .fontDesign(.libraryFontDesign(globalViewModel.activeLibraryType))
                            .padding(.bottom, 7)
                        Text(description)
                        
                        if !(viewModel.item.isLocal ?? false) {
                            Divider()
                                .padding(.vertical, 20)
                        }
                    }
                    
                    if !(viewModel.item.isLocal ?? false) {
                        BookDetailGrid()
                        
                        Divider()
                            .padding(.vertical, 20)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                BookDetailSeries()
            }
        }
    }
}
