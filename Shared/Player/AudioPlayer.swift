//
//  AudioPlayer.swift
//  Books
//
//  Created by Rasmus Krämer on 30.01.23.
//

import Foundation
import AVKit

class AudioPlayer: NSObject {
    // Parameters
    private let itemId: String
    private let episodeId: String?
    
    private let playMethod: PlayMethod
    private let audioTracks: [AudioTrack]
    
    // Player
    private let player: AVQueuePlayer
    private let user = PersistenceController.shared.getLoggedInUser()!
    
    private(set) var buffering: Bool = true
    
    private var currentTrackIndex: Int
    private var desiredPlaybackRate: Float = PlayerHelper.getDefaultPlaybackRate()
    
    init(itemId: String, episodeId: String? = nil, startTime: Double, playMethod: PlayMethod, audioTracks: [AudioTrack]) {
        self.itemId = itemId
        self.episodeId = episodeId
        self.playMethod = playMethod
        self.audioTracks = audioTracks.sorted {
            $0.index ?? 0 < $1.index ?? 0
        }
        
        self.player = AVQueuePlayer()
        self.currentTrackIndex = audioTracks.filter { $0.startOffset + $0.duration > startTime }.first!.index ?? 0

        super.init()
        
        // player.volume = 0.0
        
        setupTimeObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(itemEnded), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        updateQueueTracks(time: startTime, forceStart: true)
    }
    
    // MARK: - Public functions
    public func getCurrentTime() -> Double {
        getTimeUntil(trackIndex: currentTrackIndex) + player.currentTime().seconds
    }
    public func getTotalDuration() -> Double {
        audioTracks.reduce(0) { $0 + $1.duration }
    }
    
    public func seek(to time: Double) {
        let track = getTrack(includes: time)
        
        if track.index ?? 0 == currentTrackIndex {
            player.seek(to: CMTime(seconds: time - track.startOffset, preferredTimescale: 1000))
        } else {
            updateQueueTracks(time: time)
        }
    }
    
    // MARK: - Events
    private func setupTimeObserver() {
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.25, preferredTimescale: 1000), queue: nil) { _ in
            self.buffering = !(self.player.currentItem?.isPlaybackLikelyToKeepUp ?? false)
        }
    }
    
    @objc private func itemEnded() {
        if currentTrackIndex == audioTracks[audioTracks.count - 1].index ?? 0 {
            print("PLAYER ENDED")
        } else {
            // This *could* cause problems, but it *should* be fine
            currentTrackIndex += 1
            print("Item / Track changed to index \(currentTrackIndex)")
        }
    }
    
    // MARK: - Helper
    private func updateQueueTracks(time: Double, forceStart: Bool = false) {
        let resume = player.rate > 0 || forceStart
        
        player.pause()
        player.removeAllItems()
        
        currentTrackIndex = getTrack(includes: time).index ?? 0
        
        let tracks = getActiveTracks(after: time)
        tracks.forEach {
            player.insert(getItem(audioTrack: $0), after: nil)
        }
        
        if let item = getActiveTracks(after: time).first {
            player.seek(to: CMTime(seconds: time - item.startOffset, preferredTimescale: 1000))
        }
        if resume {
            player.rate = desiredPlaybackRate
        }
    }
    private func getItem(audioTrack: AudioTrack) -> AVPlayerItem {
        return AVPlayerItem(url: user.serverUrl!
            .appending(path: audioTrack.contentUrl)
            .appending(queryItems: [
                URLQueryItem(name: "token", value: user.token)
            ]))
    }
    
    private func getActiveTracks(after: Double) -> [AudioTrack] {
        if after == 0 {
            return audioTracks
        }
        
        return audioTracks.filter { track in
            if track.startOffset > after {
                return true
            }
            
            if track.startOffset + track.duration > after {
                return true
            }
            
            return false
        }
    }
    private func getTrack(includes: Double) -> AudioTrack {
        audioTracks.filter { $0.startOffset <= includes && $0.startOffset + $0.duration > includes }.first!
    }
    
    private func getTimeUntil(trackIndex: Int) -> Double {
        audioTracks.filter { $0.index ?? 0 < trackIndex }.reduce(0) { $0 + $1.duration }
    }
}
