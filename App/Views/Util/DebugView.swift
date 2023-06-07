//
//  DebugView.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

/// View only used for debug purposes
struct DebugView: View {
    @EnvironmentObject var globalViewModel: GlobalViewModel
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id, order: .reverse)]) var cachedMediaProgresses: FetchedResults<CachedMediaProgress>
    
    @State var search: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Group {
                    Button {
                        globalViewModel.logout()
                    } label: {
                        Text("Logout")
                    }
                    Button {
                        PersistenceController.shared.syncEntities()
                    } label: {
                        Text("sync to server")
                    }
                    Button {
                        try! PersistenceController.shared.deleteAllCachedSessions()
                    } label: {
                        Text("Clear progress cache")
                    }
                    Button {
                        PersistenceController.shared.flushKeyValueStorage()
                    } label: {
                        Text("Flush key-value storage")
                    }
                    Button {
                        PersistenceController.shared.removeAllLocalItems()
                    } label: {
                        Text("Clear local items")
                    }
                    Button {
                        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                        let fileManager = FileManager.default
                        
                        try! fileManager.contentsOfDirectory(atPath: url.path()).forEach { path in
                            try! FileManager.default.removeItem(at: url.appending(path: path))
                        }
                    } label: {
                        Text("Delete documents folder")
                    }
                    Button {
                        DownloadManager.shared.cancelDownloads()
                    } label: {
                        Text("Cancel pending tasks")
                    }
                }
                
                Text("Downloaded tracks")
                    .foregroundColor(.red)
                
                ForEach(PersistenceController.shared.getDownloadedTracks()) { download in
                    HStack {
                        Text(download.forItem ?? "_")
                        Text(download.index.description)
                        Text(download.ext ?? "?")
                        Text(download.identifier.description)
                    }
                }
                
                Text("Local Items")
                    .foregroundColor(.red)
                
                ForEach(PersistenceController.shared.getLocalItems()) { item in
                    HStack {
                        Text(item.itemId ?? "_")
                        Text(item.episodeId ?? "_")
                        Text(item.title ?? "_")
                    }
                }
                
                Text("Cached progress")
                    .foregroundColor(.red)
                
                Text(PersistenceController.shared.getLoggedInUser()?.token ?? "Not logged in")
                    .textSelection(.enabled)
                    .fontDesign(.monospaced)
                
                ForEach(cachedMediaProgresses.filter { progress in
                    if search == "" {
                        return true
                    }
                    
                    return progress.id?.contains(search) ?? false
                }) { progress in
                    HStack {
                        Text(progress.id ?? "_")
                        Divider()
                        Text(String(progress.progress))
                            .font(.caption)
                    }
                }
            }
            .searchable(text: $search)
        }
    }
}
