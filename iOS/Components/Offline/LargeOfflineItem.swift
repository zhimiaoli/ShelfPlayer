//
//  LargeOfflineItem.swift
//  Books
//
//  Created by Rasmus Krämer on 05.02.23.
//

import SwiftUI

struct LargeOfflineItem: View {
    let item: LocalItem

    var body: some View {
        NavigationLink(destination: DetailView(item: item.convertToItem())) {
            HStack {
                OfflineItemImage(url: DownloadHelper.getCover(itemId: item.itemId!, episodeId: item.episodeId), size: 50)
                    .padding(.trailing, 7)
                
                VStack(alignment: .leading) {
                    if item.episodeId == nil {
                        Text(item.title ?? "unknown title")
                        Text(item.author ?? "unknown author")
                            .font(.caption)
                    } else {
                        Text(item.episodeTitle ?? "unknown title")
                        Text(item.title ?? "unknown podcast")
                            .font(.caption)
                    }
                }
                .lineLimit(1)
                
                Spacer()
            }
            .foregroundColor(.primary)
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
