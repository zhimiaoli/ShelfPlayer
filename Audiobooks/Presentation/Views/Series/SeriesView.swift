//
//  SeriesView.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 05.10.23.
//

import SwiftUI

struct SeriesView: View {
    @Environment(\.libraryId) var libraryId
    
    let series: Series
    
    @State var audiobooks = [Audiobook]()
    @State var displayOrder = AudiobooksSort.getDisplayType()
    @State var sortOrder = AudiobooksSort.getSortOrder()
    
    var body: some View {
        Group {
            let sorted = AudiobooksSort.sort(audiobooks: audiobooks, order: sortOrder)
            
            if displayOrder == .grid {
                ScrollView {
                    AudiobookGrid(audiobooks: sorted)
                        .padding(.horizontal)
                }
            } else if displayOrder == .list {
                List {
                    AudiobooksList(audiobooks: sorted)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(series.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AudiobooksSort(display: $displayOrder, sort: $sortOrder)
            }
        }
        .task(fetchAudiobooks)
        .refreshable(action: fetchAudiobooks)
    }
}

// MARK: Helper

extension SeriesView {
    @Sendable
    func fetchAudiobooks() {
        Task.detached {
            audiobooks = (try? await AudiobookshelfClient.shared.getAudiobooksInSeries(seriesId: series.id, libraryId: libraryId)) ?? []
        }
    }
}
