//
//  FilterResponse.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import Foundation

struct FilterResponse: Codable {
    var results: [LibraryItem]
}
