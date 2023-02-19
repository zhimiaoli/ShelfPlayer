//
//  String+Padding.swift
//  Books
//
//  Created by Rasmus Krämer on 30.01.23.
//

import Foundation

extension String {
    func leftPadding(toLength: Int, withPad: String) -> String {
        String(String(reversed()).padding(toLength: toLength, withPad: withPad, startingAt: 0).reversed())
    }
}
