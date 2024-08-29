//
//  AuthorsView.swift
//  iOS
//
//  Created by Rasmus Krämer on 07.01.24.
//

import SwiftUI
import Defaults
import ShelfPlayerKit

internal struct AuthorsView: View {
    @Environment(\.libraryId) private var libraryId
    @Default(.authorsAscending) private var authorsAscending
    
    @State private var failed = false
    @State private var authors = [Author]()
    
    private var sorted: [Author] {
        authors.sorted {
            $0.name.localizedStandardCompare($1.name) == (authorsAscending ? .orderedDescending : .orderedAscending)
        }
    }
    
    var body: some View {
        if authors.isEmpty {
            if failed {
                ErrorView()
                    .refreshable {
                        await loadAuthors()
                    }
            } else {
                LoadingView()
                    .task {
                        await loadAuthors()
                    }
            }
        } else {
            List {
                AuthorList(authors: sorted)
            }
            .listStyle(.plain)
            .navigationTitle("authors.title")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle("ascending", systemImage: authorsAscending ? "arrowshape.up.circle.fill" : "arrowshape.down.circle.fill", isOn: $authorsAscending)
                        .foregroundStyle(Color.accentColor)
                        .contentTransition(.symbolEffect(.replace))
                        .toggleStyle(.button)
                        .buttonStyle(.plain)
                }
            }
            .refreshable {
                await loadAuthors()
            }
        }
    }
    
    private nonisolated func loadAuthors() async {
        guard let authors = try? await AudiobookshelfClient.shared.authors(libraryId: libraryId) else {
            await MainActor.run {
                failed = true
            }
            
            return
        }
        
        await MainActor.withAnimation {
            self.authors = authors
        }
    }
}

#Preview {
    AuthorsView()
}
