//
//  View+BecomingVisible.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import Foundation
import SwiftUI

// https://stackoverflow.com/questions/60595900/how-to-check-if-a-view-is-displayed-on-the-screen-swift-5-and-swiftui
public extension View {
    func onBecomingVisible(perform action: @escaping () -> Void) -> some View {
        modifier(BecomingVisible(action: action, fireWhenVisible: true))
    }
    func onBecomingInvisible(perform action: @escaping () -> Void) -> some View {
        modifier(BecomingVisible(action: action, fireWhenVisible: false))
    }
}

private struct BecomingVisible: ViewModifier {
    var action: (() -> Void)?
    var fireWhenVisible: Bool

    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: VisibleKey.self,
                        // See discussion!
                        value: UIScreen.main.bounds.intersects(proxy.frame(in: .global))
                    )
                    .onPreferenceChange(VisibleKey.self) { isVisible in
                        if isVisible && fireWhenVisible {
                            action?()
                        } else if !isVisible && !fireWhenVisible {
                            action?()
                        }
                    }
            }
        }
    }

    struct VisibleKey: PreferenceKey {
        static var defaultValue: Bool = false
        static func reduce(value: inout Bool, nextValue: () -> Bool) { }
    }
}
