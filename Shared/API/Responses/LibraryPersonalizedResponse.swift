//
//  LibraryPersonalizedResponse.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import Foundation

struct PersonalizedLibraryRow: Codable, Identifiable {
    let id: String
    let label: String
    let type: String
    
    let entities: [LibraryItem]
}
