//
//  ContentView.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var globalViewModel: GlobalViewModel = GlobalViewModel()
    
    var body: some View {
        Group {
            switch globalViewModel.onlineStatus {
            case .unknown:
                FullscreenLoadingIndicator(description: "Authorizing")
                    .onAppear {
                        globalViewModel.loggedIn = PersistenceController.shared.getLoggedInUser() != nil
                    }
                    .onAppear {
                        Task.detached {
                            await globalViewModel.authorize()
                        }
                    }
                // TODO: add "go offline" button
            case .offline:
                if globalViewModel.loggedIn {
                    Text("This is not implemented yet...")
                } else {
                    LoginView()
                }
            case .online:
                NavigationRoot()
            }
        }
        .onReceive(NSNotification.PlayerFinished, perform: { _ in
            globalViewModel.closePlayer()
        })
        .environmentObject(globalViewModel)
    }
}
