//
//  SeriesBanner.swift
//  Books
//
//  Created by Rasmus Krämer on 27.01.23.
//

import SwiftUI

struct SeriesBanner: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("View all series")
                    Image(systemName: "chevron.right.circle")
                }
                .font(.footnote)
                .bold()
                Text("Show all series available on this server")
                    .font(.caption)
            }
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.accentColor)
        .foregroundColor(.primary)
    }
}

struct SeriesBanner_Previews: PreviewProvider {
    static var previews: some View {
        SeriesBanner()
    }
}
