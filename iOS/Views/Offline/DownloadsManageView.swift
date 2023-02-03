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
                    var item = LibraryItem(
                        id: localItem.itemId ?? "_",
                        ino: nil,
                        libraryId: nil,
                        folderId: nil,
                        path: nil,
                        mediaType: nil,
                        type: localItem.episodeId == nil ? "book" : "podcast",
                        addedAt: Double(Date().millisecondsSince1970 / 1000),
                        updatedAt: nil,
                        isMissing: false,
                        isInvalid: false,
                        size: nil,
                        books: nil,
                        numEpisodes: nil,
                        name: localItem.title,
                        description: localItem.descriptionText,
                        numBooks: nil,
                        imagePath: nil
                    )
                    
                    if localItem.episodeId != nil {
                        let epeisode = LibraryItem.PodcastEpisode(id: localItem.episodeId, libraryItemId: localItem.itemId, index: nil, season: nil, episode: nil, title: localItem.episodeTitle, description: localItem.episodeDescription, publishedAt: nil, addedAt: nil, updatedAt: nil, size: nil, duration: localItem.duration, audioFile: nil, audioTrack: nil)
                        
                        item.recentEpisode = epeisode
                    }
                    
                    let tracks: [AudioTrack] = DownloadHelper.getLocalFiles(id: DownloadHelper.getIdentifier(itemId: localItem.itemId ?? "_", episodeId: localItem.episodeId))?.enumerated().map { index, element in
                        // TODO: fuck
                        AudioTrack(index: index, startOffset: 0, duration: 100, contentUrl: element.path(), metadata: nil)
                    } ?? []
                    
                    globalViewModel.playLocalItem(item: item, tracks: tracks)
                } label: {
                    HStack {
                        Text(localItem.title ?? "?")
                        Text(String(localItem.hasConflict))
                    }
                }
            }
        }
    }
}
