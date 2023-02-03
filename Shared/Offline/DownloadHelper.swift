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
        
        var tracks = [(URL, String)]()
        if item.isPodcast {
            if let track = item.recentEpisode?.audioTrack {
                if var url = PersistenceController.shared.getLoggedInUser()?.serverUrl?.appending(path: track.contentUrl) {
                    url.append(queryItems: [
                        URLQueryItem(name: "token", value: PersistenceController.shared.getLoggedInUser()?.token)
                    ])
                    tracks.append((url, track.metadata?.ext ?? "mp3"))
                }
            }
        } else if item.isBook {
            if let audioTracks = item.media?.tracks {
                audioTracks.sorted(by: { $0.index ?? 0 < $1.index ?? 0 }).forEach { track in
                    if var url = PersistenceController.shared.getLoggedInUser()?.serverUrl?.appending(path: track.contentUrl) {
                        url.append(queryItems: [
                            URLQueryItem(name: "token", value: PersistenceController.shared.getLoggedInUser()?.token)
                        ])
                        tracks.append((url, track.metadata?.ext ?? "mp3"))
                    }
                }
            }
        }
        
        if tracks.count <= 0 {
            return false
        }
        
        if let localItem = PersistenceController.shared.getLocalItem(itemId: item.id, episodeId: item.recentEpisode?.id) {
            NSLog("tried to download existing local item \(localItem.hasConflict)")
            return false
        }
        
        let localItem = LocalItem(context: PersistenceController.shared.container.viewContext)
        
        localItem.itemId = item.id
        localItem.title = item.media?.metadata.title ?? "unknown title"
        localItem.author = item.author
        localItem.descriptionText = item.description
        
        localItem.episodeId = item.recentEpisode?.id
        localItem.episodeTitle = item.recentEpisode?.title
        localItem.episodeDescription = item.recentEpisode?.description
        
        localItem.hasConflict = false
        localItem.downloaded = false
        localItem.duration = localItem.duration
        localItem.numFiles = Int16(tracks.count)
        
        try! PersistenceController.shared.container.viewContext.save()
        
        tracks.enumerated().forEach { index, turple in
            DownloadManager.shared.startDownload(url: turple.0, ext: turple.1, itemId: item.id, episodeId: item.recentEpisode?.id, index: index)
        }
        
        return true
    }
    
    public static func getLocalFiles(id: String) -> [URL]? {
        var urls = [URL]()
        
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appending(path: id)
            
            try FileManager.default.contentsOfDirectory(atPath: url.path()).forEach { path in
                urls.append(url.appending(path: path))
            }
            
            return urls
        } catch {
            print(error)
            return nil
        }
    }
    public static func getIdentifier(itemId: String, episodeId: String?) -> String {
        "\(itemId)--\(episodeId ?? "book")"
    }
}
