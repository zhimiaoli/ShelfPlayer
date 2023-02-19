//
//  Date+Delta.swift
//  Books
//
//  Created by Rasmus Krämer on 05.02.23.
//

import Foundation

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
