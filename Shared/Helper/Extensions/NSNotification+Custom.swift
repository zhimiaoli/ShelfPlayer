//
//  NSNotification+Custom.swift
//  Books
//
//  Created by Rasmus Krämer on 29.01.23.
//

import Foundation

extension NSNotification {
    static let PodcastSettingsUpdated = Notification.Name.init("io.rfk.audiobooks.podcast.settings.updated")
    static let ItemUpdated = Notification.Name.init("io.rfk.audiobooks.item.updated")
    
    static let PlayerSettingsUpdated = Notification.Name.init("io.rfk.audiobooks.player.settings.updated")
    
    static let LibrarySettingsUpdated = Notification.Name.init("io.rfk.audiobooks.library.settings.updated")
    static let ItemGridSortOrderUpdated = Notification.Name.init("io.rfk.audiobooks.items.sort.updated")
}
