//
//  AudioPlayer.swift
//  Books
//
//  Created by Rasmus Krämer on 30.01.23.
//

import Foundation
import AVKit
import MediaPlayer

class AudioPlayer: NSObject {
    // MARK: - Parameters
    private let sessionId: String?
    private let itemId: String
    private let episodeId: String?
    
    private let playMethod: PlayMethod
    private let audioTracks: [AudioTrack]
    
    // MARK: - Player variables
    private let player: AVQueuePlayer
    private let user = PersistenceController.shared.getLoggedInUser()!
    
    private(set) var buffering: Bool = true
    private var expectsToBePlaying: Bool = false
    
    private var currentTrackIndex: Int
    private(set) var desiredPlaybackRate: Float = PlayerHelper.getDefaultPlaybackRate()
    
    // MARK: - Playback reporting
    private var timeListened: Double = 0
    
    // MARK: - Initializers
    init(sessionId: String?, itemId: String, episodeId: String? = nil, startTime: Double, playMethod: PlayMethod, audioTracks: [AudioTrack]) {
        self.sessionId = sessionId
        self.itemId = itemId
        self.episodeId = episodeId
        self.playMethod = playMethod
        self.audioTracks = audioTracks.sorted {
            $0.index ?? 0 < $1.index ?? 0
        }
        
        self.player = AVQueuePlayer()
        self.currentTrackIndex = audioTracks.filter { $0.startOffset + $0.duration > startTime }.first!.index ?? 0
        
        super.init()
        
        setupRemoteControls()
        setupAudioSession()
        setupTimeObserver()
        
        PlayerHelper.setNowPlayingMetadata(itemId: itemId, episodeId: episodeId)
        NotificationCenter.default.addObserver(self, selector: #selector(itemEnded), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        updateQueueTracks(time: startTime, forceStart: true)
    }
    public func destroy() {
        sync()
        
        player.pause()
        player.removeAllItems()
        
        PlayerHelper.resetNowPlayingInfo()
    }
    
    // MARK: - Public functions
    public func getCurrentTime() -> Double {
        getTimeUntil(trackIndex: currentTrackIndex) + player.currentTime().seconds
    }
    public func getTotalDuration() -> Double {
        audioTracks.reduce(0) { $0 + $1.duration }
    }
    public func isPlaying() -> Bool {
        player.rate > 0
    }
    
    public func seek(to time: Double) {
        let track = getTrack(includes: time)
        
        if track.index ?? 0 == currentTrackIndex {
            player.seek(to: CMTime(seconds: time - track.startOffset, preferredTimescale: 1000))
        } else {
            updateQueueTracks(time: time)
        }
    }
    public func setPlaybackrate(_ rate: Float) {
        desiredPlaybackRate = rate
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.PlayerRateChanged, object: nil)
        }
        
        if isPlaying() {
            player.rate = rate
        }
    }
    public func setPlaying(_ playing: Bool) {
        self.expectsToBePlaying = playing
        player.rate = isPlaying() ? 0 : desiredPlaybackRate
        
        updateAudioSession(active: playing)
        sync()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.PlayerStateChanged, object: playing)
        }
    }
    
    // MARK: - Events
    private func setupTimeObserver() {
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.25, preferredTimescale: 1000), queue: nil) { _ in
            if PlayerHelper.getUseChapterView() {
                PlayerHelper.updateNowPlayingState(duration: self.player.currentItem?.duration.seconds ?? 0, currentTime: self.player.currentTime().seconds, playbackRate: self.player.rate)
            } else {
                PlayerHelper.updateNowPlayingState(duration: self.getTotalDuration(), currentTime: self.getCurrentTime(), playbackRate: self.player.rate)
            }
            
            if self.isPlaying() != self.expectsToBePlaying {
                self.setPlaying(!self.expectsToBePlaying)
            }
            self.buffering = !(self.player.currentItem?.isPlaybackLikelyToKeepUp ?? false)
            
            if self.isPlaying() {
                self.timeListened += 0.25
            }
            if self.timeListened >= 7 {
                self.sync()
            }
        }
    }
    private func setupRemoteControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [unowned self] event in
            setPlaying(true)
            return .success
        }
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            setPlaying(false)
            return .success
        }
        commandCenter.togglePlayPauseCommand.addTarget { [unowned self] event in
            setPlaying(!isPlaying())
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            if let changePlaybackPositionCommandEvent = event as? MPChangePlaybackPositionCommandEvent {
                let positionTime = changePlaybackPositionCommandEvent.positionTime
                
                if PlayerHelper.getUseChapterView() {
                    let track = getTrack(includes: getCurrentTime())
                    seek(to: track.startOffset + positionTime)
                } else {
                    seek(to: positionTime)
                }
                return .success
            }
            
            return .commandFailed
        }
        commandCenter.changePlaybackRateCommand.supportedPlaybackRates = [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2]
        commandCenter.changePlaybackRateCommand.addTarget { [unowned self] event in
            if let changePlaybackPositionCommandEvent = event as? MPChangePlaybackRateCommandEvent {
                let playbackRate = changePlaybackPositionCommandEvent.playbackRate
                setPlaybackrate(playbackRate)
                
                return .success
            }
            
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            if currentTrackIndex + 1 >= audioTracks.count {
                return .commandFailed
            }
            
            seek(to: audioTracks[currentTrackIndex + 1].startOffset)
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            if currentTrackIndex - 1 < 0 {
                return .commandFailed
            }
            
            seek(to: audioTracks[currentTrackIndex - 1].startOffset)
            return .success
        }
        
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: PlayerHelper.getForwardsSeekDuration())]
        commandCenter.skipForwardCommand.addTarget { [unowned self] event in
            if let changePlaybackPositionCommandEvent = event as? MPSkipIntervalCommandEvent {
                let interval = changePlaybackPositionCommandEvent.interval
                seek(to: getCurrentTime() + interval)
                
                return .success
            }
            
            return .commandFailed
        }
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: PlayerHelper.getBackwardsSeekDuration())]
        commandCenter.skipBackwardCommand.addTarget { [unowned self] event in
            if let changePlaybackPositionCommandEvent = event as? MPSkipIntervalCommandEvent {
                let interval = changePlaybackPositionCommandEvent.interval
                seek(to: getCurrentTime() - interval)
                
                return .success
            }
            
            return .commandFailed
        }
    }
    
    @objc private func itemEnded() {
        if currentTrackIndex == audioTracks.last?.index ?? 0 {
            sync()
            NotificationCenter.default.post(name: NSNotification.PlayerFinished, object: nil)
        } else {
            // This *could* cause problems, but it *should* be fine
            currentTrackIndex += 1
            NSLog("Item / Track changed to index \(currentTrackIndex)")
        }
    }
    
    // MARK: - Helper
    private func updateQueueTracks(time: Double, forceStart: Bool = false) {
        let resume = isPlaying() || forceStart
        
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
            setPlaying(true)
        }
    }
    private func getItem(audioTrack: AudioTrack) -> AVPlayerItem {
        if playMethod == .local {
            return AVPlayerItem(url: URL(string: "file://\(audioTrack.contentUrl)")!)
        } else {
            // LEtS OnLy eNCodE soM cHarActeRS
            return AVPlayerItem(url: user.serverUrl!
                .appending(path: audioTrack.contentUrl.removingPercentEncoding ?? "")
                .appending(queryItems: [
                    URLQueryItem(name: "token", value: user.token)
                ]))
        }
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
        audioTracks.filter { $0.startOffset <= includes && $0.startOffset + $0.duration > includes }.first ?? audioTracks.last!
    }
    
    private func getTimeUntil(trackIndex: Int) -> Double {
        audioTracks.filter { $0.index ?? 0 < trackIndex }.reduce(0) { $0 + $1.duration }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        } catch {
            print(error, "failed to start audio session")
        }
    }
    private func updateAudioSession(active: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(active)
        } catch {
            print(error, "failed to update audio session")
        }
    }
    
    private func sync() {
        PlayerHelper.syncSession(
            sessionId: sessionId,
            itemId: itemId,
            episodeId: episodeId,
            timeListened: timeListened,
            duration: getTotalDuration(),
            currentTime: getCurrentTime()
        )
        
        self.timeListened = 0
    }
}
