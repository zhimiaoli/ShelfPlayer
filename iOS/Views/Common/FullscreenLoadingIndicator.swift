//
//  LoginFlowLoader.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI

struct FullscreenLoadingIndicator: View {
    var description: String
    var showGoOfflineButton: Bool = false
    
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack {
            Text(description)
                .foregroundColor(.gray)
            ProgressView()
            
            if showGoOfflineButton {
                Button {
                    globalViewModel.onlineStatus = .offline
                } label: {
                    Text("Go offline")
                }
                .buttonStyle(LargeButtonStyle())
                .padding(.top, 25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FullscreenLoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        FullscreenLoadingIndicator(description: "Testing connection")
    }
}
