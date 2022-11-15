//
//  KeyedDecodingContainer.swift
//  Books
//
//  Created by Rasmus Krämer on 13.11.22.
//

import Foundation

extension KeyedDecodingContainer {
    /// This does not work
    func decodePossibleString<T: Decodable>(_ type: T, forKey key: KeyedDecodingContainer<K>.Key) throws -> T {
        do {
            return try decode(T.self, forKey: key)
        } catch {
            return try decode(String.self, forKey: key) as! T
        }
    }
}
