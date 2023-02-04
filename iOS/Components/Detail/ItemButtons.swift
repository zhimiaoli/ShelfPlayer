//
//  itemButtons.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

struct ItemButtons: View {
    var item: LibraryItem
    var colorScheme: ColorScheme
    
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    @State private var downloaded = false
    @State private var downloading = false
    @State private var progress: Float = 0
    
    var body: some View {
        HStack {
            Button {
                if downloaded {
                    if let localItem = PersistenceController.shared.getLocalItem(itemId: item.id, episodeId: item.recentEpisode?.id) {
                        globalViewModel.playLocalItem(localItem)
                    }
                } else {
                    globalViewModel.playItem(item: item)
                }
            } label: {
                Label(progress > 0 && progress < 1 ? "Resume" : "Listen now", systemImage: "play.fill")
            }
            .buttonStyle(PlayNowButtonStyle(colorScheme: colorScheme))
            
            Button {
                Task.detached {
                    await DownloadHelper.downloadItem(item: item)
                }
            } label: {
                Image(systemName: "arrow.down")
            }
            .buttonStyle(SecondaryButtonStyle(colorScheme: colorScheme, specialBackground: false))
            
            Button {
                Task.detached {
                    let result = await item.toggleFinishedStatus()
                    if result {
                        DispatchQueue.main.async {
                            progress = progress == 1 ? 0 : 1
                        }
                    }
                }
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(SecondaryButtonStyle(colorScheme: colorScheme, specialBackground: progress == 1))
            
            Text(downloading ? "d" : "nd")
            Text(downloaded ? "D" : "ND")
        }
        .foregroundColor(colorScheme == .light ? .black : .white)
        .onAppear {
            progress = PersistenceController.shared.getProgressByLibraryItem(item: item)
            updateDownloadedStatus()
        }
        .onReceive(NSNotification.ItemDownloadStatusChanged, perform: { _ in
            updateDownloadedStatus()
        })
    }
    
    private func updateDownloadedStatus() {
        downloaded = PersistenceController.shared.getLocalItem(itemId: item.id, episodeId: item.recentEpisode?.id)?.isDownloaded ?? false
        downloading = DownloadManager.shared.downloading.index(forKey: DownloadHelper.getIdentifier(itemId: item.id, episodeId: item.recentEpisode?.id)) != nil
    }
}
