//
//  LocalItem+Verify.swift
//  Books
//
//  Created by Rasmus Krämer on 05.02.23.
//

import Foundation

extension LocalItem {
    public func verify() {
        let id = DownloadHelper.getIdentifier(itemId: itemId!, episodeId: episodeId)
        let files = DownloadHelper.getLocalFiles(id: id) ?? []
        
        if files.count != numFiles && ((!isDownloaded && DownloadManager.shared.downloading[id] == nil) || isDownloaded) {
            hasConflict = true
            try! PersistenceController.shared.container.viewContext.save()
        } else if files.count == numFiles {
            hasConflict = false
            isDownloaded = true
            try! PersistenceController.shared.container.viewContext.save()
        }
    }
}
