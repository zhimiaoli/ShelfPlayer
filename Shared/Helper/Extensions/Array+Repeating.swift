//
//  Array+Repeating.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 25.02.23.
//

import Foundation

extension Array {
    init(repeating: [Element], count: Int) {
        self.init([[Element]](repeating: repeating, count: count).flatMap{$0})
    }
    
    func repeated(count: Int) -> [Element] {
        return [Element](repeating: self, count: count)
    }
}
