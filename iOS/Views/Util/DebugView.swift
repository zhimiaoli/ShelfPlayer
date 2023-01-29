//
//  DebugView.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

/// View only used for debug purposes
struct DebugView: View {
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id, order: .reverse)]) private var cachedMediaProgresses: FetchedResults<CachedMediaProgress>
    
    @State private var search: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Button {
                    globalViewModel.logout()
                } label: {
                    Text("Logout")
                }
                Button {
                    try? PersistenceController.shared.deleteAllCachedSessions()
                } label: {
                    Text("Clear")
                }
                
                Text(PersistenceController.shared.getLoggedInUser()?.token ?? "Not logged in")
                    .textSelection(.enabled)
                    .font(.system(.body, design: .monospaced))
                
                ForEach(cachedMediaProgresses.filter { progress in
                    if search == "" {
                        return true
                    }
                    
                    return progress.id?.contains(search) ?? false
                }) { progress in
                    HStack {
                        Text(progress.libraryItemId ?? "?")
                        Text(progress.episodeId ?? "_")
                        Divider()
                        Text(String(progress.progress))
                            .font(.caption)
                    }
                }
            }
            .searchable(text: $search)
        }
        .tabItem {
            Label("Debug", systemImage: "gear.circle.fill")
        }
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}
