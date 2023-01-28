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
        @Binding var presentationMode: PresentationMode
        
        var body: some View {
            GeometryReader { reader in
                ScrollView(showsIndicators: false) {
                    VStack() {
                        BookDetailHeader()
                        BookDetailBody()
                            .frame(minHeight: reader.size.height - 400, alignment: .top)
                    }.background(
                        GeometryReader { proxy -> Color in
                            DispatchQueue.main.async {
                                let offset = -proxy.frame(in: .named("scroll")).origin.y - 59
                                viewModel.changeScrollViewBackground = offset < 0
                            }
                            return Color(uiColor: UIColor.systemBackground)
                        })
                }
                // Navigation bar
                .edgesIgnoringSafeArea(.top)
                .navigationTitle(viewModel.item.title)
                .navigationBarTitleDisplayMode(.inline)
                .modifier(GestureSwipeRight(action: {
                    if presentationMode.isPresented && !viewModel.isNavigationBarVisible {
                        withAnimation {
                            presentationMode.dismiss()
                        }
                    }
                }))
                
                // Toolbar
                .toolbar(viewModel.isNavigationBarVisible ? .visible : .hidden, for: .navigationBar)
                .overlay(alignment: .topLeading) {
                    if presentationMode.isPresented {
                        // A button does not work here
                        Image(systemName: "chevron.left.circle.fill")
                            .foregroundColor(.accentColor)
                            .dynamicTypeSize(.xxxLarge)
                            .symbolRenderingMode(.hierarchical)
                            .fontWeight(.bold)
                            .offset(x: 15, y: 57)
                            .ignoresSafeArea()
                            .animation(.easeInOut, value: viewModel.isNavigationBarVisible)
                            .opacity(viewModel.isNavigationBarVisible ? 0 : 1)
                            .onTapGesture {
                                withAnimation {
                                    presentationMode.dismiss()
                                }
                            }
                    }
                }
                
                // Background color
                .coordinateSpace(name: "scroll")
                .background(viewModel.changeScrollViewBackground ? Color(viewModel.backgroundColor) : Color.clear)
                .animation(.easeInOut, value: viewModel.backgroundColor)
                
                .task {
                    (viewModel.backgroundColor, viewModel.backgroundIsLight) = await ImageHelper.getAverageColor(item: viewModel.item)
                    await viewModel.getMoreBooksFromSeries()
                }
            }
            .environmentObject(viewModel)
        }
    }
}

extension DetailView {
    class ViewModel: ObservableObject {
        @Published var item: LibraryItem
        
        @Published var isNavigationBarVisible: Bool = false
        @Published var animateNavigationBarChanges: Bool = false
        
        @Published var changeScrollViewBackground = false
        @Published var backgroundColor = UIColor.secondarySystemBackground
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
