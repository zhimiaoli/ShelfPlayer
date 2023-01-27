//
//  ItemFilter.swift
//  Books
//
//  Created by Rasmus Krämer on 27.01.23.
//

enum ItemSortOrder: String, CaseIterable {
    case name = "name"
    case numBooks = "numBooks"
    case totalDuration = "totalDuration"
    case addedAt = "addedAt"
}
