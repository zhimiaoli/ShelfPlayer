//
//  SearchSeries.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import Foundation

struct SearchSeries: Codable {
    var id: String
    var name: String
    var description: String?
    var addedAt: Double?
    var updatedAt: Double?
}
