//
//  View+Recive.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import Foundation
import SwiftUI

extension View {
    func onReceive(_ name: Notification.Name, center: NotificationCenter = .default, object: AnyObject? = nil, perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(
            center.publisher(for: name, object: object), perform: action
        )
    }
}
