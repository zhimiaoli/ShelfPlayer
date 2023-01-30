//
//  AudioPlayer.swift
//  Books
//
//  Created by Rasmus Krämer on 30.01.23.
//

import Foundation
import AVKit

class AudioPlayer {
    // Parameters
    private let itemId: String
    private let episodeId: String?
    
    private let playMethod: PlayMethod
    private let audioTracks: [AudioTrack]
    
    // Player
    private let player: AVQueuePlayer
    private let realTime: Double
    
    private let user = PersistenceController.shared.getLoggedInUser()!
    
    init(itemId: String, episodeId: String? = nil, startTime: Double, playMethod: PlayMethod, audioTracks: [AudioTrack]) {
        self.itemId = itemId
        self.episodeId = episodeId
        self.realTime = startTime
        self.playMethod = playMethod
        self.audioTracks = audioTracks
        
        self.player = AVQueuePlayer()
        
        updateQueueTracks()
        
        // I don't know why, but it does work, so i am not going to question it (subtract the offset not required?)
        // Edit: i found out...
        player.seek(to: CMTime(seconds: startTime, preferredTimescale: 1000))
        player.play()
    }
    
    private func updateQueueTracks() {
        let tracks = getItemTracks(after: realTime)
        print(tracks)
        
        tracks.forEach {
            player.insert(getItem(audioTrack: $0), after: nil)
        }
    }
    
    // MARK: - Helper
    private func getItemTracks(after: Double) -> [AudioTrack] {
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
    private func getItem(audioTrack: AudioTrack) -> AVPlayerItem {
        return AVPlayerItem(url: user.serverUrl!
            .appending(path: audioTrack.contentUrl.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
            .appending(queryItems: [
                URLQueryItem(name: "token", value: user.token)
            ]))
    }
}
