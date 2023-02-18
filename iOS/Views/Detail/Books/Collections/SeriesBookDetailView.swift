//
//  BookDetailSeries.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import SwiftUI

extension DetailView {
    /// More books from the same series as the item
    struct BookDetailSeries: View {
        @EnvironmentObject private var viewModel: ViewModel
        
        var body: some View {
            if let moreBooksFromSeries = viewModel.moreBooksFromSeries {
                ItemRowContainer(title: "Also in series", destinationId: viewModel.seriesId) {
                    ItemRow(content: moreBooksFromSeries)
                }
            }
        }
    }
}
