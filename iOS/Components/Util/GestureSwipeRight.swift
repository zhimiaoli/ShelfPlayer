//
//  GestureSwipeRight.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import SwiftUI

// https://stackoverflow.com/questions/66134245/full-screen-pan-swipe-gesture-on-navigationview
struct GestureSwipeRight: ViewModifier {
    var action: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())  // This is what would make gesture
            .gesture(                   // accessible on all the View.
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.width > .zero && value.translation.height > -30 && value.translation.height < 30 {
                            action?()
                        }
                    }
            )
    }
}
