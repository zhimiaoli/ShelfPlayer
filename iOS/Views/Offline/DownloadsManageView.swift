//
//  DownloadsManageView.swift
//  Books
//
//  Created by Rasmus Krämer on 03.02.23.
//

import SwiftUI

struct DownloadsManageView: View {
    var detailed: Bool
    
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    @State var books = [LocalItem]()
    @State var podcasts = [String: [LocalItem]]()
    
    var body: some View {
        List {
            Section {
                if books.count == 0 {
                    Text("no downloaded books")
                        .font(.system(.caption, design: .rounded).smallCaps())
                }
                
                ForEach(books) { localItem in
                    if detailed {
                        LargeOfflineItem(item: localItem)
                    } else {
                        SmallOfflineItem(item: localItem)
                    }
                }
            } header: {
                Text("Books")
            }
            
            ForEach(podcasts.sorted(by: { $0.key.localizedStandardCompare($1.key) == .orderedAscending }), id: \.key) { podcast in
                Section {
                    ForEach(podcast.value) { localItem in
                        if detailed {
                            LargeOfflineItem(item: localItem)
                        } else {
                            SmallOfflineItem(item: localItem)
                        }
                    }
                } header: {
                    Text(podcast.key)
                }
            }
            
            if globalViewModel.onlineStatus == .offline {
                Button {
                    globalViewModel.onlineStatus = .unknown
                } label: {
                    Text("Go online")
                }
                .foregroundColor(.accentColor)
            }
        }
        .foregroundColor(.primary)
        .onAppear {
            updateItems()
        }
        .onReceive(NSNotification.ItemDownloadStatusChanged, perform: { _ in
            updateItems()
        })
    }
    
    private func updateItems() {
        let items = DownloadHelper.getDownloadedItems(onlyPlayable: !detailed)
        
        books = items.books
        podcasts = items.podcasts
    }
}
