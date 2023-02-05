//
//  DownloadHelper.swift
//  Books
//
//  Created by Rasmus Krämer on 02.02.23.
//

import Foundation

struct DownloadHelper {
    public static func setAllowDownloadsOverMobile(_ allow: Bool) {
        PersistenceController.shared.setKey("downloads.mobile", value: allow.description)
    }
    public static func getAllowDownloadsOverMobile() -> Bool {
        let value: String = PersistenceController.shared.getValue(key: "downloads.mobile") ?? "false"
        return Bool(value) ?? false
    }
    public static func setDeleteDownloadsWhenFinished(_ delete: Bool) {
        PersistenceController.shared.setKey("downloads.delete", value: delete.description)
    }
    public static func getDeleteDownloadsWhenFinished() -> Bool {
        let value: String = PersistenceController.shared.getValue(key: "downloads.delete") ?? "true"
        return Bool(value) ?? true
    }
    
    public static func downloadItem(item libraryItem: LibraryItem) async -> Bool {
        var item: LibraryItem?
        
        if libraryItem.hasEpisode {
            guard var podcast = try? await APIClient.authorizedShared.request(APIResources.items(id: libraryItem.id).get) else {
                return false
            }
            guard let episodeId = libraryItem.recentEpisode?.id else {
                return false
            }
            
            guard let episode = podcast.media?.episodes?.first(where: { $0.id == episodeId }) else {
                return false
            }
            
            podcast.media?.episodes = nil
            podcast.recentEpisode = episode
            
            item = podcast
        } else if libraryItem.isBook {
            item = try? await APIClient.authorizedShared.request(APIResources.items(id: libraryItem.id).get)
        }
        
        guard let item = item else {
            return false
        }
        
        if let localItem = PersistenceController.shared.getLocalItem(itemId: item.id, episodeId: item.recentEpisode?.id) {
            NSLog("tried to download existing local item \(localItem.hasConflict)")
            
            if !localItem.hasConflict {
                return false
            } else {
                deleteDownload(itemId: item.id, episodeId: item.recentEpisode?.id)
            }
        }
        
        var tracks = [(URL, String, Double)]()
        if item.isPodcast {
            if let track = item.recentEpisode?.audioTrack {
                if var url = PersistenceController.shared.getLoggedInUser()?.serverUrl?.appending(path: track.contentUrl.removingPercentEncoding!) {
                    url.append(queryItems: [
                        URLQueryItem(name: "token", value: PersistenceController.shared.getLoggedInUser()?.token)
                    ])
                    tracks.append((url, track.metadata?.ext ?? "mp3", track.duration))
                }
            }
        } else if item.isBook {
            if let audioTracks = item.media?.tracks {
                audioTracks.sorted(by: { $0.index ?? 0 < $1.index ?? 0 }).forEach { track in
                    if var url = PersistenceController.shared.getLoggedInUser()?.serverUrl?.appending(path: track.contentUrl.removingPercentEncoding!) {
                        url.append(queryItems: [
                            URLQueryItem(name: "token", value: PersistenceController.shared.getLoggedInUser()?.token)
                        ])
                        tracks.append((url, track.metadata?.ext ?? "mp3", track.duration))
                    }
                }
            }
        }
        
        if tracks.count <= 0 {
            return false
        }
        
        let localItem = LocalItem(context: PersistenceController.shared.container.viewContext)
        
        localItem.itemId = item.id
        localItem.title = item.media?.metadata.title ?? "unknown title"
        localItem.author = item.author
        localItem.descriptionText = item.media?.metadata.description
        
        localItem.episodeId = item.recentEpisode?.id
        localItem.episodeTitle = item.recentEpisode?.title
        localItem.episodeDescription = item.recentEpisode?.description
        
        localItem.hasConflict = false
        localItem.duration = localItem.duration
        
        localItem.isDownloaded = false
        localItem.numFiles = Int16(tracks.count)
        
        try! PersistenceController.shared.container.viewContext.save()
        
        if let cover = item.cover {
            DownloadManager.shared.downloadCover(coverUrl: cover, id: getIdentifier(itemId: item.id, episodeId: item.recentEpisode?.id))
        }
        tracks.enumerated().forEach { index, turple in
            DownloadManager.shared.startDownload(url: turple.0, ext: turple.1, duration: turple.2, itemId: item.id, episodeId: item.recentEpisode?.id, index: index)
        }
        
        return true
    }
    public static func deleteDownload(itemId: String, episodeId: String?) {
        let id = getIdentifier(itemId: itemId, episodeId: episodeId)
        let folder = DownloadManager.shared.documentsURL.appending(path: id)
        
        try! FileManager.default.removeItem(at: folder)
        PersistenceController.shared.deleteTracks(id: id)
        PersistenceController.shared.deleteLocalItem(itemId: itemId, episodeId: episodeId)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.ItemDownloadStatusChanged, object: nil)
        }
    }
    
    public static func getLocalFiles(id: String) -> [URL]? {
        var urls = [URL]()
        
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appending(path: id)
            
            try FileManager.default.contentsOfDirectory(atPath: url.path()).forEach { path in
                if path.contains("file") {
                    urls.append(url.appending(path: path))
                }
            }
            
            return urls
        } catch {
            return nil
        }
    }
    public static func getDownloadedItems(onlyPlayable: Bool) -> (books: [LocalItem],  podcasts: [String: [LocalItem]]) {
        var items = PersistenceController.shared.getLocalItems()
        
        if onlyPlayable {
            items = items.filter {
                !$0.hasConflict && $0.isDownloaded
            }
        }
        
        var podcasts = [String: [LocalItem]]()
        let podcastItems = items.filter { $0.episodeId != nil }
        let books = items.filter { $0.episodeId == nil }
        
        podcastItems.forEach { item in
            let title = item.title ?? "Unknown podcast"
            if podcasts[title] == nil {
                podcasts[title] = []
            }
            
            podcasts[title]?.append(item)
        }
        
        return (books: books, podcasts: podcasts)
    }
    
    public static func getIdentifier(itemId: String, episodeId: String?) -> String {
        "\(itemId)--\(episodeId ?? "book")"
    }
    public static func getCover(itemId: String, episodeId: String?) -> URL? {
        DownloadManager.shared.documentsURL.appending(path: DownloadHelper.getIdentifier(itemId: itemId, episodeId: episodeId)).appending(path: "cover.png")
    }
    
    public static func getTimeUtil(_ util: Int, tracks: [DownloadTrack]) -> Double {
        tracks.enumerated().reduce(0, { previous, track in
            if track.offset < util {
                return previous + track.element.duration
            }
            
            return previous
        })
    }
}
