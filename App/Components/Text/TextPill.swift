//
//  PodcastDetailPill.swift
//  Books
//
//  Created by Rasmus Krämer on 01.02.23.
//

import SwiftUI

struct PodcastDetailPill: View {
    var text: String
    let active: Bool
    
    @Environment(\.namespace) var namespace
    
    var body: some View {
        Text(text)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background {
                if active {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.accentColor)
                        .matchedGeometryEffect(id: "podcastEpisodeListSegmentedControl", in: namespace)
                }
            }
            .animation(.spring(response: 0.25, dampingFraction: 0.75, blendDuration: 5), value: active)
            .foregroundColor(active ? .white : .primary)
            .animation(.none, value: active)
            .font(.caption)
            .bold()
    }
}

struct PodcastDetailPill_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @Namespace var namespace
        
        @State var activeIndex = 0

        var body: some View {
            HStack {
                ForEach(0..<4) { index in
                    Button {
                        withAnimation {
                            activeIndex = index
                        }
                    } label: {
                        PodcastDetailPill(text: "Hello, World!", active: activeIndex == index)
                    }
                }
            }
            .environment(\.namespace, namespace)
        }
    }
    
    static var previews: some View {
        PreviewContainer()
    }
}
