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
    
    @EnvironmentObject var globalViewModel: GlobalViewModel
    @Environment(\.scenePhase) var scenePhase
    
    @State var isDownloaded = false
    @State var isDownloading = false
    @State var hasConflict = false
    @State var progress: Float = 0
    
    @State var deleteDownloadAlertPresented: Bool = false
    
    var body: some View {
        HStack {
            Button {
                if isDownloaded {
                    if let localItem = PersistenceController.shared.getLocalItem(itemId: item.id, episodeId: item.recentEpisode?.id) {
                        globalViewModel.playLocalItem(localItem)
                    }
                } else {
                    globalViewModel.playItem(item: item)
                }
                
                Haptics.shared.play(.medium)
            } label: {
                Label(progress > 0 && progress < 1 ? "Resume" : "Listen now", systemImage: "play.fill")
            }
            .buttonStyle(PlayNowButtonStyle(colorScheme: colorScheme))
            
            Button {
                if isDownloaded {
                    deleteDownloadAlertPresented.toggle()
                } else {
                    hasConflict = false
                    
                    Task.detached {
                        await DownloadHelper.downloadItem(item: item)
                    }
                }
                
                Haptics.shared.play(.light)
            } label: {
                if isDownloading {
                    ProgressView()
                        .tint(colorScheme == .light ? .black : .white)
                } else {
                    Image(systemName: "arrow.down")
                }
            }
            .buttonStyle(SecondaryButtonStyle(colorScheme: colorScheme, backgroundColor: hasConflict ? .red : isDownloaded ? .accentColor : nil))
            
            Button {
                Task.detached {
                    let result = await item.toggleFinishedStatus()
                    if result {
                        DispatchQueue.main.async {
                            progress = progress == 1 ? 0 : 1
                        }
                    }
                }
                
                Haptics.shared.play(.light)
            } label: {
                if(progress > 0 && progress < 1) {
                    Text("\(Int(progress * 100))%")
                } else {
                    Image(systemName: "checkmark")
                }
            }
            .buttonStyle(SecondaryButtonStyle(colorScheme: colorScheme, backgroundColor: progress == 1 ? .accentColor : nil))
        }
        .foregroundColor(colorScheme == .light ? .black : .white)
        .alert("Delete download", isPresented: $deleteDownloadAlertPresented, actions: {
            Button(role: .destructive) {
                DownloadHelper.deleteDownload(itemId: item.id, episodeId: item.recentEpisode?.id)
                
                isDownloaded = false
                hasConflict = false
                isDownloading = false
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {} label: {
                Text("Cancel")
            }
        }, message: {
            Text("Are you sure you want to delete this download?")
        })
        .onAppear {
            progress = PersistenceController.shared.getProgressByLibraryItem(item: item)
            updateDownloadedStatus()
        }
        .onReceive(NSNotification.ItemDownloadStatusChanged, perform: { _ in
            updateDownloadedStatus()
        })
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                updateDownloadedStatus()
            }
        }
    }
    
    private func updateDownloadedStatus() {
        if let entity = PersistenceController.shared.getLocalItem(itemId: item.id, episodeId: item.recentEpisode?.id) {
            hasConflict = entity.hasConflict
            isDownloaded = entity.isDownloaded
        }
        
        isDownloading = DownloadManager.shared.downloading.index(forKey: DownloadHelper.getIdentifier(itemId: item.id, episodeId: item.recentEpisode?.id)) != nil
    }
}
