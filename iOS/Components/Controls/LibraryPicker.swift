//
//  LibraryPicker.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

struct LibraryPicker: View {
    @State var libraries: [Library]?
    
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    var body: some View {
        if let libraries = libraries {
            Menu {
                ForEach(libraries, id: \.id) { library in
                    Button {
                        withAnimation {
                            globalViewModel.selectLibrary(libraryId: library.id, type: library.mediaType)
                        }
                    } label: {
                        Group {
                            if library.mediaType == "book" {
                                Label(library.name, systemImage: "books.vertical.fill")
                            } else if library.mediaType == "podcast" {
                                Label(library.name, systemImage: "mic.fill")
                            } else {
                                Text(library.name)
                            }
                        }
                        // Does not work...
                        // .foregroundColor(globalViewModel.activeLibraryId == library.id ? .accentColor : .primary)
                    }
                }
                
                Button {
                    globalViewModel.settingsSheetPresented.toggle()
                } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            } label: {
                Image(systemName: "books.vertical.circle")
            }
        }
        
        Color.clear
            .onAppear {
                Task.detached {
                    await getLibraries()
                }
            }
    }
    
    @Sendable private func getLibraries() async {
        libraries = try? await APIClient.authorizedShared.request(APIResources.libraries.get()).libraries
    }
}
