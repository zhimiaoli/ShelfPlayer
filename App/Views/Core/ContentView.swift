//
//  ContentView.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    var body: some View {
        Group {
            switch globalViewModel.onlineStatus {
            case .unknown:
                FullscreenLoadingIndicator(description: "Authorizing", showGoOfflineButton: globalViewModel.loggedIn)
                .onAppear {
                    globalViewModel.loggedIn = PersistenceController.shared.getLoggedInUser() != nil
                    
                    Task.detached {
                        await globalViewModel.authorize()
                    }
                }
            case .offline:
                if globalViewModel.loggedIn {
                    NavigationView {
                        NowPlayingWrapper {
                            DownloadsManageView(detailed: true)
                        }
                    }
                } else {
                    LoginView()
                }
            case .online:
                NavigationRoot()
            }
        }
        .onReceive(NSNotification.PlayerFinished, perform: { _ in
            if DownloadHelper.getDeleteDownloadsWhenFinished() && PersistenceController.shared.getLocalItem(itemId: globalViewModel.currentlyPlaying!.id, episodeId: globalViewModel.currentlyPlaying?.recentEpisode?.id) != nil {
                DownloadHelper.deleteDownload(itemId: globalViewModel.currentlyPlaying!.id, episodeId: globalViewModel.currentlyPlaying?.recentEpisode?.id)
            }
            
            globalViewModel.closePlayer()
        })
        .onReceive(NSNotification.ItemDownloadStatusChanged, perform: { _ in
            globalViewModel.isItemStillAvaiable()
        })
        .onReceive(NSNotification.PodcastSettingsUpdated, perform: playLightHaptic)
        .onReceive(NSNotification.LibrarySettingsUpdated, perform: playLightHaptic)
    }
    
    private func playLightHaptic(_: Any) {
        Haptics.shared.play(.light)
    }
}
