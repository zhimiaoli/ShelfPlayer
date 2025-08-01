//
//  Defaults+Keys.swift
//  iOS
//
//  Created by Rasmus Krämer on 03.02.24.
//

import Foundation
import ShelfPlayback

extension Defaults.Keys {
    static let lastTabValue = Key<TabValue?>("lastTabValue")
    
    static let carPlayTabBarLibraries = Key<[Library]?>("carPlayTabBarLibraries", default: nil)
    static let carPlayShowListenNow = Key<Bool>("carPlayShowListenNow", default: true)
    static let carPlayShowOtherLibraries = Key<Bool>("carPlayShowOtherLibraries", default: true)
}

extension RFNotification.IsolatedNotification {
    static var setGlobalSearch: IsolatedNotification<String> { .init("io.rfk.shelfPlayer.setGlobalSearch") }
    static var presentGlobalSearch: IsolatedNotification<RFNotificationEmptyPayload> { .init("io.rfk.shelfPlayer.presentGlobalSearch") }
    
    static var focusSearchField: IsolatedNotification<RFNotificationEmptyPayload> { .init("io.rfk.shelfPlayer.focusSearchField") }
    
    static var navigateConditionMet: IsolatedNotification<RFNotificationEmptyPayload> { .init("io.rfk.shelfPlayer.navigate.notify") }
    static var _navigate: IsolatedNotification<ItemIdentifier> { .init("io.rfk.shelfPlayer.navigate.two") }
    
    static var changeLibrary: IsolatedNotification<Library> { .init("io.rfk.shelfPlayer.changeLibrary") }
    static var changeOfflineMode: IsolatedNotification<Bool> { .init("io.rfk.shelfPlayer.changeOfflineMode") }
    
    static var performBackgroundSessionSync: IsolatedNotification<ItemIdentifier.ConnectionID?> { .init("io.rfk.shelfPlayer.performBackgroundSessionSync") }
    
    static var scenePhaseDidChange: IsolatedNotification<Bool> { .init("io.rfk.shelfPlayer.scenePhaseDidChange") }
}
