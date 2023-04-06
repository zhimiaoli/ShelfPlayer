//
//  Font+Library.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 06.04.23.
//

import SwiftUI

extension Font.Design {
    public static func libraryFontDesign(_ libraryType: String?) -> Font.Design {
        libraryType == "book" ? .serif : libraryType == "podcast" ? .default : .default
    }
}
