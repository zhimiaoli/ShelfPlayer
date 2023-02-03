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
    
    @State private var progress: Float = 0
    
    var body: some View {
        HStack {
            Button {
                globalViewModel.playItem(item: item)
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
        }
        .foregroundColor(colorScheme == .light ? .black : .white)
        .onAppear {
            progress = PersistenceController.shared.getProgressByLibraryItem(item: item)
        }
    }
}
