//
//  FilterHelper.swift
//  Books
//
//  Created by Rasmus Krämer on 29.01.23.
//

import Foundation

struct FilterHelper {
    public static func filterEpisodes(_ episodes: [LibraryItem.PodcastEpisode], filter: EpisodeFilter) -> [LibraryItem.PodcastEpisode] {
        return episodes.filter { episode in
            if filter == .all {
                return true
            } else {
                let progress = PersistenceController.shared.getProgressByPodcastEpisode(episode: episode)
                
                if filter == .inProgress && progress > 0 && progress < 1 {
                    return true
                } else if filter == .finished && progress == 1 {
                    return true
                } else if filter == .unFinished && progress < 1 {
                    return true
                }
            }
            return false
        }
    }
    public static func sortEpisodes(_ episodes: [LibraryItem.PodcastEpisode], sortOrder: EpisodeSort, invert: Bool = false) -> [LibraryItem.PodcastEpisode] {
        return episodes.sorted {
            var result = false
            
            if sortOrder == .date {
                result = $0.publishedAt ?? 0 < $1.publishedAt ?? 0
            } else if sortOrder == .episode {
                result = $0.index ?? 0 < $1.index ?? 0
            } else if sortOrder == .title {
                result = $0.title ?? "" < $1.title ?? ""
            }
            
            if invert {
                return !result
            } else {
                return result
            }
        }
    }
    
    public static func getDefaultFilter(podcastId: String) -> EpisodeFilter {
        let value: String = PersistenceController.shared.getValue(key: "filter.\(podcastId)") ?? ""
        return EpisodeFilter(rawValue: value) ?? .all
    }
    public static func setDefaultFilter(podcastId: String, filter: EpisodeFilter) {
        PersistenceController.shared.setKey("filter.\(podcastId)", value: filter.rawValue)
    }
}
