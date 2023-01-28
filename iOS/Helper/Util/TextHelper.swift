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
}
