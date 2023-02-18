//
//  LibraryItem+Methods.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 18.02.23.
//

import Foundation

extension LibraryItem {
    func toggleFinishedStatus() async -> Bool {
        if isBook || (isPodcast && hasEpisode) {
            do {
                let progress = PersistenceController.shared.getProgressByLibraryItem(item: self)
                var progressId: String = id
                
                if hasEpisode {
                    progressId.append("/")
                    progressId.append(recentEpisode?.id ?? "")
                }
                
                try await APIClient.authorizedShared.request(APIResources.progress(id: progressId).finished(finished: progress != 1))
                PersistenceController.shared.updateStatusWithoutUpdate(item: self, progress: progress == 1 ? 0 : 1)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.ItemUpdated, object: nil)
                }
                
                return true
            } catch {
                let duration = media?.duration ?? recentEpisode?.duration ?? 1
                PersistenceController.shared.updateStatus(itemId: id, episodeId: recentEpisode?.id, currentTime: duration, duration: duration)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.ItemUpdated, object: nil)
                }
                
                return true
            }
        }
        
        return false
    }
}
