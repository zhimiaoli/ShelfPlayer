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
    
    public static func setUseChapterView(_ use: Bool) {
        PersistenceController.shared.setKey("player.book.chapter", value: use.description)
    }
    public static func getUseChapterView() -> Bool {
        let value: String = PersistenceController.shared.getValue(key: "player.book.chapter") ?? "true"
        return Bool(value) ?? true
    }
}
