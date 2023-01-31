//
//  PlayResponse.swift
//  Books
//
//  Created by Rasmus Krämer on 30.01.23.
//

import Foundation

struct PlayResponse: Codable {
    let id: String
    let userId: String
    let libraryId: String
    let libraryItemId: String
    let episodeId: String?
    
    // let metadata: LibraryItem.LibraryItemMetadata
    let playMethod: Int
    let startTime: Double
    
    let audioTracks: [AudioTrack]
    let chapters: [Chapter]
    
    struct Chapter: Codable {
        let id: Int
        let start: Double
        let end: Double
        let title: String
    }
}
