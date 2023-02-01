//
//  SearchResponse.swift
//  Books
//
//  Created by Rasmus Krämer on 01.02.23.
//

import Foundation

struct SearchResponse<T: Codable>: Codable {
    var podcast: [SearchItem<T>]?
    var book: [SearchItem<T>]?
    var authors: [T]
    var series: [SearchSeries<T>]
    
    struct SearchItem<T: Codable>: Codable {
        let libraryItem: T
    }
    struct SearchSeries<T: Codable>: Codable {
        let series: T
    }
}
