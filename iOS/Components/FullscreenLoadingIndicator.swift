//
//  LoginFlowLoader.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI

struct FullscreenLoadingIndicator: View {
    var description: String
    
    var body: some View {
        VStack {
            Text(description)
                .foregroundColor(.gray)
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FullscreenLoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        FullscreenLoadingIndicator(description: "Testing connection")
    }
}
