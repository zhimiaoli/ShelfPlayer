//
//  DownloadHelper.swift
//  Books
//
//  Created by Rasmus Krämer on 02.02.23.
//

import Foundation

struct DownloadHelper {
    public static func setAllowDownloadsOverMobile(_ allow: Bool) {
        PersistenceController.shared.setKey("downloads.mobile", value: allow.description)
    }
    public static func getAllowDownloadsOverMobile() -> Bool {
        let value: String = PersistenceController.shared.getValue(key: "downloads.mobile") ?? "false"
        return Bool(value) ?? false
    }
    
    public static func downloadItem(item: LibraryItem) {
        
    }
}
