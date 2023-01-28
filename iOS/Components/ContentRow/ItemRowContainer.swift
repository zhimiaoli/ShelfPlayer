//
//  ItemRowContainer.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct ItemRowContainer<Content: View>: View {
    var title: String?
    var destinationId: String?
    var appearence: Size = .normal
    @ViewBuilder var content: Content
    
    @Environment(\.colorScheme) var colorScheme
    @State private var size: CGFloat = 175
    
    var body: some View {
        GeometryReader { reader in
            VStack(alignment: .leading) {
                if let title = title {
                    let text = Text(title)
                        .font(.system(.body, design: .serif))
                        .dynamicTypeSize(.xxLarge)
                    
                    Group {
                        if let destinationId = destinationId {
                            NavigationLink(destination: DetailView(id: destinationId)) {
                                HStack {
                                    text
                                        .foregroundColor(.primary)
                                    
                                    Image(systemName: "chevron.right.circle")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        } else {
                            text
                        }
                    }
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
                
                if appearence == .small {
                    size /= 1.75
                    size -= 23
                } else if appearence == .large {
                    size *= 2
                    size += 20
                }
            }
            .environment(\.itemRowItemWidth, $size)
        }
        .frame(height: size + 80)
    }
    
    enum Size {
        case large
        case normal
        case small
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
