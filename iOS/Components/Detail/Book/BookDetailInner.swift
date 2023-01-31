//
//  BookDetailInner.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import SwiftUI

extension DetailView {
    /// Detail view for books
    struct BookDetailInner: View {
        @StateObject var viewModel: ViewModel
        @EnvironmentObject var fullscreenViewModel: FullscrenViewViewModel
        
        var body: some View {
            Group {
                BookDetailHeader()
                BookDetailBody()
            }
            .navigationTitle(viewModel.item.title)
            .onAppear {
                Task.detached {
                    let (backgroundColor, backgroundIsLight) = await ImageHelper.getAverageColor(item: viewModel.item)
                    await viewModel.getMoreBooksFromSeries()
                    
                    DispatchQueue.main.async {
                        fullscreenViewModel.backgroundColor = backgroundColor
                        viewModel.backgroundIsLight = backgroundIsLight
                    }
                }
            }
            .environmentObject(viewModel)
        }
    }
}

extension DetailView {
    class ViewModel: ObservableObject {
        @Published var item: LibraryItem
        
        @Published var backgroundIsLight = UIColor.secondarySystemBackground.isLight() ?? false
        
        @Published var seriesId: String?
        @Published var moreBooksFromSeries: [LibraryItem]?
        
        init(item: LibraryItem) {
            self.item = item
        }
        
        @Sendable public func getMoreBooksFromSeries() async {
            // Parse the series name
            guard let series = item.media?.metadata.seriesName else {
                return
            }
            let seriesName: String
            
            if series.contains("#") {
                seriesName = series.split(separator: " #")[0].description
            } else {
                seriesName = series
            }
            
            // Retrive the series id
            guard let searchSeries = try? await APIClient.authorizedShared.request(APIResources.series.seriesByName(search: seriesName)).results else {
                return
            }
            if searchSeries.count == 0 {
                return
            }
            
            // Retrive more books from the series
            guard let libraryId = item.libraryId else {
                return
            }
            
            let books = try? await APIClient.authorizedShared.request(APIResources.libraries(id: libraryId).items(filter: "series.\(searchSeries[0].id.toBase64())")).results
            DispatchQueue.main.async {
                self.seriesId = searchSeries[0].id
                self.moreBooksFromSeries = books
            }
        }
    }
}
