//
//  ContentView.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI
import CoreData

private enum OnlineStatus {
    case unknown
    case offline
    case online
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var user: User? = PersistenceController.shared.getLoggedInUser()
    @State private var onlineStatus: OnlineStatus = .unknown
    
    var body: some View {
        if user != nil {
            Group {
                switch onlineStatus {
                case .unknown:
                    FullscreenLoadingIndicator(description: "Logging in")
                        .task(authorize)
                case .offline:
                    Text("This is not implemented yet...")
                case .online:
                    NavigationRoot()
                }
            }
            .onReceive(.logout) { _ in
                logout()
            }
        } else {
            LoginView() {
                user = PersistenceController.shared.getLoggedInUser()
                APIClient.updateAuthorizedClient()
            }
        }
    }
    
    @Sendable private func authorize() async {
        do {
            let _ = try await APIClient.authorizedShared.request(APIResources.ping.get)
        } catch {
            return onlineStatus = .offline
        }
        
        do {
            let authorizeResponse = try await APIClient.authorizedShared.request(APIResources.authorize.post)
            DispatchQueue.global(qos: .background).async {
                PersistenceController.shared.updateMediaProgressDatabase(authorizeResponse.user.mediaProgress)
            }
            onlineStatus = .online
        } catch {
            logout()
        }
    }
    private func logout() {
        try! PersistenceController.shared.deleteLoggedInUser()
        try! PersistenceController.shared.deleteAllCachedSessions()
        APIClient.updateAuthorizedClient()
        user = nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
