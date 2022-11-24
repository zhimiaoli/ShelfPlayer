//
//  ItemImage.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct ItemImage: View {
    var id: String
    private let user = PersistenceController.shared.getLoggedInUser()!
    
    var body: some View {
        AsyncImage(url: user.serverUrl!.appending(path: "/api/items").appending(path: id).appending(path: "cover").appending(queryItems: [URLQueryItem(name: "token", value: user.token)])) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(7)
            } else if phase.error != nil {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Image(systemName: "book")
                            .dynamicTypeSize(.xLarge)
                        Spacer()
                    }
                    Spacer()
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(7)
            } else {
                ProgressView()
            }
        }
        .frame(width: 175, height: 175)
    }
}
