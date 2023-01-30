//
//  Library.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import Foundation

/// Library containg items retrived from the ABS server
struct Library: Codable {
    var id: String
    var name: String
    var displayOrder: Int
    var mediaType: String
}
