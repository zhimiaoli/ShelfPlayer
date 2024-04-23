//
//  FullscreenToolbarModifier.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 04.10.23.
//

import SwiftUI

struct FullscreenToolbarModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    let navigationBarVisible: Bool
    
    var isLight: Bool? = nil
    var accentColor: Color = .accent
    
    private var appearance: ColorScheme {
        if isLight == true {
            return .light
        } else if isLight == false {
            return .dark
        } else {
            return colorScheme
        }
    }
    
    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular {
            content
                .symbolVariant(.circle)
        } else {
            content
                .symbolVariant(.circle.fill)
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    navigationBarVisible ? accentColor : appearance == .light ? .black : .white,
                    navigationBarVisible ? .gray.opacity(0.1) : .black.opacity(0.25))
        }
    }
}
