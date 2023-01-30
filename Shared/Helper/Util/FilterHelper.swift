//
//  FilterHelper.swift
//  Books
//
//  Created by Rasmus Krämer on 29.01.23.
//

import Foundation

struct FilterHelper {
    private(set) static var defaultFilter: EpisodeFilter = getDefaultFilter(fallback: .all)
    private(set) static var defaultSortOrder: EpisodeSort = getDefaultSortOrder(fallback: .episode)
    private(set) static var defaultInvert: Bool = getDefaultInvert(fallback: false)
    
    // MARK: - Podcast filter settings
    public static func getDefaultFilter(podcastId: String) -> EpisodeFilter {
        let value: String = PersistenceController.shared.getValue(key: "filter.\(podcastId)") ?? ""
        return EpisodeFilter(rawValue: value) ?? defaultFilter
    }
    public static func setDefaultFilter(podcastId: String, filter: EpisodeFilter) {
        PersistenceController.shared.setKey("filter.\(podcastId)", value: filter.rawValue)
    }
    
    public static func getDefaultSortOrder(podcastId: String) -> (EpisodeSort, Bool) {
        let value: String = PersistenceController.shared.getValue(key: "sort.\(podcastId)") ?? ""
        let invert: String = PersistenceController.shared.getValue(key: "sort_invert.\(podcastId)") ?? defaultInvert.description
        
        return (EpisodeSort(rawValue: value) ?? defaultSortOrder, Bool(invert) ?? defaultInvert)
    }
    public static func setDefaultSortOrder(podcastId: String, order: EpisodeSort, invert: Bool) {
        PersistenceController.shared.setKey("sort.\(podcastId)", value: order.rawValue)
        PersistenceController.shared.setKey("sort_invert.\(podcastId)", value: invert.description)
    }
    
    // MARK: - Global filter settings
    public static func setDefaultFilter(filter: EpisodeFilter) {
        PersistenceController.shared.setKey("filter", value: filter.rawValue)
        defaultFilter = filter
    }
    public static func getDefaultFilter(fallback: EpisodeFilter? = nil) -> EpisodeFilter {
        let value: String = PersistenceController.shared.getValue(key: "filter") ?? ""
        return EpisodeFilter(rawValue: value) ?? fallback ?? defaultFilter
    }
    
    public static func setDefaultSortOrder(order: EpisodeSort) {
        PersistenceController.shared.setKey("sort", value: order.rawValue)
        defaultSortOrder = order
    }
    public static func getDefaultSortOrder(fallback: EpisodeSort? = nil) -> EpisodeSort {
        let value: String = PersistenceController.shared.getValue(key: "sort") ?? ""
        return EpisodeSort(rawValue: value) ?? fallback ?? defaultSortOrder
    }
    
    public static func setDefaultInvert(invert: Bool) {
        PersistenceController.shared.setKey("sort_invert", value: invert.description)
        defaultInvert = invert
    }
    public static func getDefaultInvert(fallback: Bool? = nil) -> Bool {
        let value: String = PersistenceController.shared.getValue(key: "sort_invert") ?? fallback?.description ?? "false"
        return Bool(value) ?? fallback ?? defaultInvert
    }
    
    // MARK: - Library filter
    public static func setDefaultLibrarySortOrder(order: ItemSort, mediaType: String) {
        PersistenceController.shared.setKey("library.sort.\(mediaType)", value: order.rawValue)
    }
    public static func getDefaultLibrarySortOrder(mediaType: String) -> ItemSort {
        let value: String = PersistenceController.shared.getValue(key: "library.sort.\(mediaType)") ?? ""
        return ItemSort(rawValue: value) ?? .title
    }
    
    public static func getSortLabel(item: ItemSort) -> String {
        switch item {
        case .title:
            return "Title"
        case .size:
            return "Size"
            
        case .author:
            return "Author"
        case .narrator:
            return "Narrator"
        case .seriesName:
            return "Series"
        case .publishedYear:
            return "Year"
        case .addedAt:
            return "Added at"
            
        case .podcastAuthor:
            return "Author"
        }
    }
    
    // MARK: - sort & filter methods
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
    public static func sortEpisodes(_ episodes: [LibraryItem.PodcastEpisode], sortOrder: EpisodeSort, invert: Bool) -> [LibraryItem.PodcastEpisode] {
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
    public static func sortEpisodes(_ episodes: [LibraryItem.PodcastEpisode], _ sort: (EpisodeSort, Bool)) -> [LibraryItem.PodcastEpisode] {
        sortEpisodes(episodes, sortOrder: sort.0, invert: sort.1)
    }
    
    public static func filterCases(_ item: ItemSort, libraryType: String) -> Bool {
        var allowed: [ItemSort] = [.title, .size]
        
        if libraryType == "book" {
            allowed = [.title, .author, .narrator, .seriesName, .publishedYear, .addedAt, .size]
        } else if libraryType == "podcast" {
            allowed = [.title, .podcastAuthor, .size]
        }
        
        return allowed.contains(item)
    }
}
