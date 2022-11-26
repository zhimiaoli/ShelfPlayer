//
//  ItemRowContainer.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct ItemRowContainer<Content: View>: View {
    var title: String?
    
    @Environment(\.colorScheme) var colorScheme
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = title {
                Text(title)
                    .font(.system(.body, design: .serif))
                    .dynamicTypeSize(.xxLarge)
                    .bold()
                    .padding(.horizontal, 20)
                    .padding(.bottom, -10)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack() {
                    content
                }
                .padding()
            }
            .background {
                if colorScheme == .light {
                    LinearGradient(colors: [.white, .gray.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                }
            }
        }
        .padding(.vertical, title == nil ? 0 : 10)
    }
}
