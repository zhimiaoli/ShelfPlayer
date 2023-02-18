//
//  LibrariesResponse.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import Foundation

struct LibrariesResponse<T: Codable>: Codable {
    var libraries: [T]
}
