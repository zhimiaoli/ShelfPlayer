//
//  BooksApp.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI

@main
struct BooksApp: App {
    @StateObject var globalViewModel = GlobalViewModel()
    let persistenceController = PersistenceController.shared
    
    @State var libraries = [Library]()
    
    init() {
        var newYorkFont: UIFont {
            let descriptor = UIFont.systemFont(ofSize: 34, weight: .bold).fontDescriptor
            if let serif = descriptor.withDesign(.serif) {
                return UIFont(descriptor: serif, size: 0.0)
            }
            return UIFont(descriptor: descriptor, size: 0.0)
        }
        
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: newYorkFont]
        UINavigationBar.appearance().titleTextAttributes = [.font: newYorkFont.withSize(17)]
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(globalViewModel)
                .onAppear {
                    Task.detached {
                        await getLibraries()
                    }
                }
        }
        .commands {
            CommandMenu("Library") {
                ForEach(libraries, id: \.id) { library in
                    Button {
                        withAnimation {
                            globalViewModel.selectLibrary(libraryId: library.id, type: library.mediaType)
                        }
                    } label: {
                        Text(library.name)
                    }
                }
            }
        }
    }
    
    private func getLibraries() async {
        libraries = (try? await APIClient.authorizedShared.request(APIResources.libraries.get()).libraries) ?? []
    }
}
