//
//  File.swift
//  
//
//  Created by Rasmus Krämer on 13.05.24.
//

import Foundation
import SPFoundation
import SPOffline

public extension Episode {
    static func filterSort(episodes: [Episode], filter: ItemFilter, sortOrder: EpisodeSortOrder, ascending: Bool) -> [Episode] {
        var episodes = episodes
        
        if filter != .all {
            episodes = episodes.filter {
                let entity = OfflineManager.shared.progressEntity(item: $0)
                
                if entity.progress > 0 {
                    if filter == .unfinished {
                        return entity.progress < 1
                    }
                    if entity.progress < 1 && filter == .finished {
                        return false
                    }
                    if entity.isFinished && filter == .progress {
                        return false
                    }
                    
                    return true
                } else {
                    if filter == .unfinished {
                        return true
                    } else {
                        return false
                    }
                }
            }
        }
        
        episodes.sort {
            switch sortOrder {
                case .name:
                    return $0.name.localizedStandardCompare($1.name) == .orderedAscending
                case .index:
                    return $0.index < $1.index
                case .released:
                    guard let lhsReleaseDate = $0.releaseDate else { return false }
                    guard let rhsReleaseDate = $1.releaseDate else { return true }
                    
                    return lhsReleaseDate < rhsReleaseDate
                case .duration:
                    return $0.duration < $1.duration
            }
        }
        
        if ascending {
            return episodes
        } else {
            return episodes.reversed()
        }
    }
}
