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
    
    var body: some View {
        Text(text)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(active ? Color.accentColor : Color.gray.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(15)
            .font(.caption)
    }
}

struct PodcastDetailPill_Previews: PreviewProvider {
    static var previews: some View {
        PodcastDetailPill(text: "Hello, World!", active: true)
    }
}
