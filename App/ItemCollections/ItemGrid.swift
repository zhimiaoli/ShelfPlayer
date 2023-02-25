//
//  Itemgrid.swift
//  Books
//
//  Created by Rasmus Krämer on 24.01.23.
//

import SwiftUI

struct ItemGrid: View {
    var content: [LibraryItem]
    
    @State var size: CGFloat = 0
    @State var amount: Int = 2
    
    var body: some View {
        GeometryReader { reader in
            ScrollView(.vertical, showsIndicators: false) {
                if size != 0 {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: amount)) {
                        ForEach(content, id: \.identifier) { item in
                            ItemRowItem(item: item, size: size, shadow: true)
                                .padding(.vertical, 5)
                        }
                    }
                }
            }
            .onAppear {
                calculateItemWidth(reader.size.width)
            }
            .onChange(of: reader.size) { _ in
                calculateItemWidth(reader.size.width)
            }
        }
        .padding(.horizontal, 15)
    }
    
    private func calculateItemWidth(_ width: CGFloat) {
        #if targetEnvironment(macCatalyst)
        let width = Float(width)
        var minWidth: Float = 250

        minWidth += 10

        let additional = width.truncatingRemainder(dividingBy: minWidth)
        
        amount = Int((width - additional) / minWidth)
        size = CGFloat(minWidth - 10 - 10 / additional + additional / Float(amount))

        #else
        size = (width - 30) / 2
        #endif
    }
}
