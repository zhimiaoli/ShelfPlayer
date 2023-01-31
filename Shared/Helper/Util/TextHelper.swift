//
//  TextHelper.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import Foundation
import SwiftSoup

struct TextHelper {
    public static func parseHTML(_ html: String) -> String {
        do {
            let cleaned = try SwiftSoup.clean(html, Whitelist.basic())!
            let document: Document = try SwiftSoup.parse(cleaned)
            return try document.text()
        } catch {
            return "error while parsing description"
        }
    }
    
    public static func formatTime(tourple: (String, String, String), forceHours: Bool = false) -> String {
        if tourple.0 == "0" && !forceHours {
            return "\(tourple.1):\(tourple.2)"
        } else {
            return "\(tourple.0):\(tourple.1)"
        }
    }
    
    public static func formatRemainingTime(seconds: Int) -> String {
        let (h, m, s) = Date.secondsToHoursMinutesSeconds(seconds)
        
        if seconds < 60 {
            return "\(s) seconds remaining"
        } else if seconds < 3_600 {
            return "\(m) minutes remaining"
        } else {
            return "\(h) hours remaining"
        }
    }
}
