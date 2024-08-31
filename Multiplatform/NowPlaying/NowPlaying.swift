//
//  NowPlaying.swift
//  Multiplatform
//
//  Created by Rasmus Krämer on 04.05.24.
//

import SwiftUI
import UIKit
import AVKit

struct NowPlaying {
    private init() {}
}

internal extension NowPlaying {
    static let widthChangeNotification = NSNotification.Name("io.rfk.ampfin.sidebar.width.changed")
    static let offsetChangeNotification = NSNotification.Name("io.rfk.ampfin.sidebar.offset.changed")
}
