//
//  ContentView.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var user: User? = PersistenceController.shared.getLoggedInUser()
    
    var body: some View {
        if let user = user {
            Text(user.username!)
            Text(user.token!)
        } else {
            LoginView() {
                user = PersistenceController.shared.getLoggedInUser()
                APIClient.updateAuthorizedClient()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
