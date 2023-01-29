//
//  FilterSelector.swift
//  Books
//
//  Created by Rasmus Krämer on 29.01.23.
//

import SwiftUI

struct FilterSelector: View {
    @Binding var selectedFilter: EpisodeFilter
    @Binding var selectedSortOrder: EpisodeSort
    @Binding var sortInvert: Bool
    
    var body: some View {
        Section {
            Picker("Filter", selection: $selectedFilter) {
                ForEach(EpisodeFilter.allCases, id: \.rawValue) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            
            Picker("Sort", selection: $selectedSortOrder) {
                ForEach(EpisodeSort.allCases, id: \.rawValue) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            Toggle("Invert", isOn: $sortInvert)
        } header: {
            Text("Filter & Sort")
        } footer: {
            Text("This filter will be applied by default")
        }
    }
}
