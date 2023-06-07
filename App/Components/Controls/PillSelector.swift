//
//  PillSelector.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 02.06.23.
//

import SwiftUI

struct PillSelector: View {
    @Namespace var namespace
    
    @Binding var activeIndex: Int?
    
    var items: [String]
    var pillWidth: CGFloat = 100
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    Text(item)
                        .foregroundColor(.primary)
                        .modifier(TextModifier())
                        .overlay {
                            // Selector
                            if activeIndex == index {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.accentColor)
                                    .matchedGeometryEffect(id: "podcastEpisodeListSegmentedControl", in: namespace, isSource: activeIndex == index)
                            }
                        }
                        .animation(.spring(response: 0.15, dampingFraction: 0.65 , blendDuration: 0), value: activeIndex)
                        .frame(width: pillWidth)
                }
            }
            // Make the text white when the selector is on top of it
            .overlay(alignment: .topLeading) {
                HStack {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        Text(item)
                            .foregroundColor(.white)
                            .modifier(TextModifier())
                            .frame(width: pillWidth)
                            .onTapGesture {
                                if activeIndex == index {
                                    activeIndex = nil
                                } else {
                                    activeIndex = index
                                }
                            }
                    }
                }
                .mask(alignment: .topLeading) {
                    // Clip text through selector
                    Rectangle()
                        .frame(width: pillWidth)
                        .offset(x: (pillWidth + 10) * CGFloat(activeIndex ?? -1))
                        .animation(.spring(response: 0.15, dampingFraction: 0.65, blendDuration: 0), value: activeIndex)
                }
            }
            .padding(.horizontal, 10)
        }
    }
    
    struct TextModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .font(.caption)
                .bold()
        }
    }
}

struct PillSelector_Previews: PreviewProvider {
    @State static var activeIndex: Int? = 0
    static var previews: some View {
        PillSelector(activeIndex: $activeIndex, items: ["Season 1", "Season 2", "Season 3", "Season 4", "Season 5", "Season 6"])
    }
}
