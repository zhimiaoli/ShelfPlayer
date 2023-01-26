//
//  ItemRowContainer.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct ItemRowContainer<Content: View>: View {
    var title: String?
    var appearence: Size = .normal
    
    @Environment(\.colorScheme) var colorScheme
    @ViewBuilder var content: Content
    
    @State private var size: CGFloat = 175
    
    var body: some View {
        GeometryReader { reader in
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
                    .padding(.horizontal, 15)
                    .padding(.vertical)
                }
                .background {
                    if colorScheme == .light {
                        LinearGradient(colors: [.white, .gray.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                    }
                }
            }
            .padding(.vertical, title == nil ? 0 : 10)
            .onAppear {
                size = (reader.size.width - 60) / 2
                
                if appearence == .smaller {
                    size /= 1.75
                    size -= 23
                }
            }
            .environment(\.itemRowItemWidth, $size)
        }
        .frame(height: size + 80)
    }
    
    enum Size {
        case normal
        case smaller
    }
}

private struct ItemRowItemWidth: EnvironmentKey {
    static var defaultValue: Binding<CGFloat> = .constant(175)
}
extension EnvironmentValues {
    var itemRowItemWidth: Binding<CGFloat> {
        get { self[ItemRowItemWidth.self] }
        set { self[ItemRowItemWidth.self] = newValue }
    }
}
