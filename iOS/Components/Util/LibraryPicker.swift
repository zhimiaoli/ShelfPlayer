//
//  LibraryPicker.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

struct LibraryPicker: View {
    @State var libraries: [Library]?
    
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    var body: some View {
        if let libraries = libraries {
            Menu {
                ForEach(libraries, id: \.id) { library in
                    Button {
                        globalViewModel.selectLibrary(libraryId: library.id)
                    } label: {
                        if library.mediaType == "book" {
                            Label(library.name, systemImage: "books.vertical.fill")
                        } else if library.mediaType == "podcast" {
                            Label(library.name, systemImage: "mic.fill")
                        } else {
                            Text(library.name)
                        }
                    }
                }
            } label: {
                Image(systemName: "books.vertical.circle")
            }
        }
        
        Color.clear.task(getLibraries)
    }
    
    @Sendable private func getLibraries() async {
        libraries = try? await APIClient.authorizedShared.request(APIResources.libraries.get()).libraries
    }
}
