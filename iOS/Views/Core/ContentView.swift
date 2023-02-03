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
                FullscreenLoadingIndicator(description: "Authorizing", showGoOfflineButton: true)
                .onAppear {
                    globalViewModel.loggedIn = PersistenceController.shared.getLoggedInUser() != nil
                    
                    Task.detached {
                        // await globalViewModel.authorize()
                    }
                }
            case .offline:
                if globalViewModel.loggedIn {
                    NowPlayingWrapper {
                        DownloadsManageView()
                    }
                } else {
                    LoginView()
                }
            case .online:
                NavigationRoot()
            }
        }
        .environmentObject(globalViewModel)
        .onReceive(NSNotification.PlayerFinished, perform: { _ in
            globalViewModel.closePlayer()
        })
    }
}
