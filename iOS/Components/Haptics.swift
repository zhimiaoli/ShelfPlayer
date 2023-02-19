//
//  Haptics.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 19.02.23.
//

import Foundation
import UIKit

// https://stackoverflow.com/questions/56748539/how-to-create-haptic-feedback-for-a-button-in-swiftui
class Haptics {
    static let shared = Haptics()
    
    private init() { }

    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
