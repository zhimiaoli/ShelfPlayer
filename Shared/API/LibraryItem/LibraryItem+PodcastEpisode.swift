//
//  LibraryItem+PodcastEpisode.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 18.02.23.
//

import Foundation

extension LibraryItem {
    struct PodcastEpisode: Codable {
        var id: String?
        var libraryItemId: String?
        var index: Int?
        var season: String?
        var episode: String?
        var title: String?
        var description: String?
        
        var publishedAt: Double?
        var addedAt: Double?
        var updatedAt: Double?
        
        var size: Double?
        var duration: Double?
        
        var audioFile: PodcastAudioFile?
        var audioTrack: AudioTrack?
        
        init(id: String?, libraryItemId: String?, title: String?, description: String?, duration: Double?) {
            self.id = id
            self.libraryItemId = libraryItemId
            self.title = title
            self.description = description
            self.duration = duration
        }
        
        // why?
        var seasonData: (season: String?, episode: String?) {
            var season: String?
            var episode: String?
            
            if self.season != "" {
                season = self.season
            }
            if self.episode != "" {
                episode = self.episode
            }
            
            return (season: season, episode: episode)
        }
        var length: Double {
            duration ?? audioFile?.duration ?? 0
        }
        
        struct PodcastAudioFile: Codable {
            var duration: Double?
            var codec: String?
            var channelLayout: String?
            
            var metadata: PodcastMetadata?
        }
        struct PodcastMetadata: Codable {
            var size: Double?
        }
    }
}
