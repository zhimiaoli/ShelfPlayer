//
//  DownloadsManageView.swift
//  Books
//
//  Created by Rasmus Krämer on 03.02.23.
//

import SwiftUI

struct DownloadsManageView: View {
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    @State var items = PersistenceController.shared.getLocalItems()
    
    var body: some View {
        List {
            ForEach(items) { localItem in
                Button {
                    globalViewModel.playLocalItem(localItem)
                } label: {
                    HStack {
                        Text(localItem.title ?? "?")
                        if !localItem.isDownloaded {
                            Text("(downloading...)")
                                .foregroundColor(.gray)
                        }
                        if localItem.hasConflict {
                            Text("(conflict)")
                                .foregroundColor(.red)
                        }
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        DownloadHelper.deleteDownload(itemId: localItem.itemId!, episodeId: localItem.episodeId)
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                }
            }
            
            if globalViewModel.onlineStatus == .offline {
                Button {
                    globalViewModel.onlineStatus = .unknown
                } label: {
                    Text("Go online")
                }
                .foregroundColor(.accentColor)
            }
        }
        .foregroundColor(.primary)
    }
}
