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
    var shadow: Bool = false
    
    @State private var progressPercentage: Float = 0
    @State private var actualSize: CGFloat = 175
    
    @Environment(\.itemRowItemWidth) private var enviromentSize
    
    var body: some View {
        NavigationLink(destination: DetailView(item: item)) {
            VStack(alignment: item.isAuthor ? .center : .leading) {
                if !item.isSeries {
                    ItemImage(item: item, size: actualSize)
                } else {
                    if let books = item.books, books.count > 0 {
                        Group {
                            if books.count == 1 {
                                ItemImage(item: books[0], size: actualSize)
                            } else {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                                    if books.count <= 3 {
                                        let even = item.title.count % 2 == 0
                                        
                                        if even {
                                            Spacer()
                                        }
                                        ItemImage(item: books[0], size: actualSize / 2)
                                            .offset(x: even ? -10 : 10, y: 10)
                                        if !even {
                                            Spacer()
                                            Spacer()
                                        }
                                        ItemImage(item: books[1], size: actualSize / 2)
                                            .offset(x: even ? 10 : -10, y: -10)
                                    } else {
                                        let gridItemSize = (actualSize / 2) - 4
                                        
                                        ItemImage(item: books[0], size: gridItemSize)
                                        ItemImage(item: books[1], size: gridItemSize)
                                        ItemImage(item: books[2], size: gridItemSize)
                                        ItemImage(item: books[3], size: gridItemSize)
                                    }
                                }
                            }
                        }
                        .background(.gray.opacity(0.1))
                        .cornerRadius(7)
                        .shadow(radius: shadow ? 2 : 0)
                    } else {
                        ItemImage(item: nil, size: actualSize)
                    }
                }
                
                HStack {
                    Text(verbatim: item.title)
                        .font(.system(.caption, design: .serif))
                        .bold()
                        .tint(.primary)
                    
                    if !item.isAuthor {
                        Spacer()
                    }
                    
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
                            .offset(y: -1)
                    }
                }
                .frame(height: 15)
            }
            .frame(width: actualSize)
            .onAppear {
                progressPercentage = PersistenceController.shared.getProgressByLibraryItem(item: item)
            }
        }
        .onAppear {
            actualSize = size ?? enviromentSize.wrappedValue
        }
    }
}
