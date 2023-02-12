//
//  CachedmediaPorgress+JSON.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 12.02.23.
//

import Foundation

extension CachedMediaProgress {
    func convertToDict() -> [String: Any] {
        return [
            "id": id!,
            "libraryItemId": libraryItemId!,
            "episodeId": episodeId ?? "",
            "duration": duration,
            "progress": progress,
            "currentTime": currentTime,
            "isFinished": isFinished,
            "hideFromContinueListening": hideFromContinueListening,
            "lastUpdate": Double(lastUpdate?.millisecondsSince1970 ?? 0),
            "startedAt": Double(startedAt?.millisecondsSince1970 ?? 0),
            "finishedAt": "",
        ]
    }
}
