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
        } else if navigationBarVisible {
            content
                .symbolVariant(.circle)
                .animation(.easeInOut, value: navigationBarVisible)
        } else {
            content
                .symbolVariant(.circle.fill)
                .symbolRenderingMode(.palette)
                .foregroundStyle(appearance == .light ? .black : .white, .black.opacity(0.25))
                .animation(.easeInOut, value: navigationBarVisible)
        }
    }
}
