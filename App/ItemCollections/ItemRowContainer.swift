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
    
    @EnvironmentObject var globalViewModel: GlobalViewModel
    @Environment(\.colorScheme) var colorScheme
    @State var size: CGFloat = 175
    
    var body: some View {
        GeometryReader { reader in
            VStack(alignment: .leading) {
                if let title = title {
                    Group {
                        let text = Text(title)
                            .fontDesign(.libraryFontDesign(globalViewModel.activeLibraryType))
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
                    }
                    .padding(.bottom, -3)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack() {
                        content
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .background {
                    if colorScheme == .light {
                        LinearGradient(colors: [.white, .gray.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                    }
                }
            }
            .padding(.top, title == nil ? 0 : 10)
            .onAppear {
                calculateItemWidth(reader.size.width)
            }
            .onChange(of: reader.size) { _ in
                calculateItemWidth(reader.size.width)
            }
            .environment(\.itemRowItemWidth, $size)
        }
        .frame(height: size + 80)
    }
    
    private func calculateItemWidth(_ width: CGFloat) {
        #if targetEnvironment(macCatalyst)
        let width = Float(width)
        var minWidth: Float = 250

        if appearence == .small {
            minWidth = 100
        }

        minWidth += 20

        let additional = width.truncatingRemainder(dividingBy: minWidth)
        let amount = (width - additional) / minWidth

        size = CGFloat(minWidth - 20 - 20 / additional + additional / amount)

        #else
        size = (width - 60) / 2

        if appearence == .small {
            size /= 1.75
            size -= 23
        } else if appearence == .large {
            size *= 2
            size += 20
        }
        #endif
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
