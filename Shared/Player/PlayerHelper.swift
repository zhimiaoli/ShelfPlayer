//
//  PlayerHelper.swift
//  Books
//
//  Created by Rasmus Krämer on 30.01.23.
//

import Foundation

struct PlayerHelper {
    public static var audioPlayer: AudioPlayer?
    
    public static func getDefaultPlaybackRate() -> Float {
        return 1.0
    }
}
