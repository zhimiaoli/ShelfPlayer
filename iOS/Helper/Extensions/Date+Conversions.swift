//
//  Date+Conversions.swift
//  Books
//
//  Created by Rasmus Krämer on 23.01.23.
//

import Foundation

extension Date {
    static func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
