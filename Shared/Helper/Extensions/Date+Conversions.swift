//
//  Date+Conversions.swift
//  Books
//
//  Created by Rasmus Krämer on 23.01.23.
//

import Foundation

extension Date {
    static func secondsToHoursMinutesSeconds(_ seconds: Int) -> (String, String, String) {
        return (
            "\(seconds / 3600)".leftPadding(toLength: 1, withPad: "0"),
            "\((seconds % 3600) / 60)".leftPadding(toLength: 2, withPad: "0"),
            "\((seconds % 3600) % 60)".leftPadding(toLength: 2, withPad: "0")
        )
    }
}
