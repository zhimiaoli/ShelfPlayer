//
//  SmallOfflineItem.swift
//  Books
//
//  Created by Rasmus Krämer on 05.02.23.
//

import SwiftUI

struct SmallOfflineItem: View {
    let item: LocalItem
    
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    var body: some View {
        Button {
            globalViewModel.playLocalItem(item)
        } label: {
            HStack {
                Text(item.episodeTitle ?? item.title ?? "?")
                if item.hasConflict {
                    Text("(conflict)")
                        .foregroundColor(.red)
                } else if !item.isDownloaded {
                    Text("(downloading...)")
                        .foregroundColor(.gray)
                }
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                DownloadHelper.deleteDownload(itemId: item.itemId!, episodeId: item.episodeId)
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
    }
}
