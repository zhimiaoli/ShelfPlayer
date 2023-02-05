//
//  PlayerHelper.swift
//  Books
//
//  Created by Rasmus Krämer on 30.01.23.
//

import Foundation
import MediaPlayer

struct PlayerHelper {
    public static var audioPlayer: AudioPlayer?
    public static func getDefaultPlaybackRate() -> Float {
        return 1.0
    }
    public static func getForwardsSeekDuration() -> Int {
        return 15
    }
    public static func getBackwardsSeekDuration() -> Int {
        return 15
    }
    
    public static func setUseChapterView(_ use: Bool) {
        PersistenceController.shared.setKey("player.book.chapter", value: use.description)
    }
    public static func getUseChapterView() -> Bool {
        let value: String = PersistenceController.shared.getValue(key: "player.book.chapter") ?? "true"
        return Bool(value) ?? true
    }
    
    private static var nowPlayingInfo = [String: Any]()
    
    // MARK: - Session reporting
    public static func syncSession(sessionId: String?, itemId: String, episodeId: String?, timeListened: Double, duration: Double, currentTime: Double) {
        if let sessionId = sessionId {
            Task.detached {
                do {
                    try await APIClient.authorizedShared.request(APIResources.session(id: sessionId).sync(timeListened: timeListened, duration: duration, currentTime: currentTime.isNaN ? 0 : currentTime))
                    PersistenceController.shared.updateStatusWithoutUpdate(itemId: itemId, episodeId: episodeId, currentTime: currentTime, progress: Float(currentTime / duration), duration: duration)
                } catch {
                    cacheSync(itemId: itemId, episodeId: episodeId, currentTime: currentTime, duration: duration)
                }
            }
        } else {
            cacheSync(itemId: itemId, episodeId: episodeId, currentTime: currentTime, duration: duration)
        }
    }
    private static func cacheSync(itemId: String, episodeId: String?, currentTime: Double, duration: Double) {
        PersistenceController.shared.updateStatus(itemId: itemId, episodeId: episodeId, currentTime: currentTime, duration: duration)
        PersistenceController.shared.syncEntities()
    }
    
    // MARK: - iOS now playing widget
    public static func setNowPlayingMetadata(itemId: String, episodeId: String?) {
        Task.detached {
            nowPlayingInfo = [:]
            
            if let item = try? await APIClient.authorizedShared.request(APIResources.items(id: itemId).get) {
                nowPlayingInfo[MPMediaItemPropertyTitle] = item.title
                nowPlayingInfo[MPMediaItemPropertyArtist] = item.author
                
                if let series = item.media?.metadata.seriesName {
                    nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = series
                }
                if let coverUrl = item.cover {
                    getData(from: coverUrl) { image in
                        let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { _ -> UIImage in image })
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                        
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    }
                } else {
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            } else if let item = PersistenceController.shared.getLocalItem(itemId: itemId, episodeId: episodeId) {
                nowPlayingInfo[MPMediaItemPropertyTitle] = item.title
                nowPlayingInfo[MPMediaItemPropertyArtist] = item.author
                
                if let coverUrl = DownloadHelper.getCover(itemId: itemId, episodeId: episodeId) {
                    getData(from: coverUrl) { image in
                        let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { _ -> UIImage in image })
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                        
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    }
                } else {
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            }
        }
    }
    public static func updateNowPlayingState(duration: Double, currentTime: Double, playbackRate: Float) {
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = getDefaultPlaybackRate()
        
        MPNowPlayingInfoCenter.default().playbackState = playbackRate > 0 ? .playing : .paused
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    public static func resetNowPlayingInfo() {
        nowPlayingInfo = [:]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    public static func getData(from url: URL, completion: @escaping (UIImage) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            }
        }).resume()
    }
}
