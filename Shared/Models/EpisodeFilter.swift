//
//  EpisodeFilter.swift
//  Books
//
//  Created by Rasmus Krämer on 29.01.23.
//

import Foundation

enum EpisodeFilter: String, CaseIterable {
    case all = "All Episodes"
    case inProgress = "In Progress"
    case unFinished = "Unfinished"
    case finished = "Finished"
}
