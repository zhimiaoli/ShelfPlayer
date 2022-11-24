//
//  LoginViewInner.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI

private enum LoginFlowState {
    case server
    case pinging
    case credentials
    case processing
}

/// Login sheet presented to the user
struct LoginViewInner: View {
    @Environment(\.managedObjectContext) private var viewContext
    var callback: (() -> Void)
    
    @State private var currentState: LoginFlowState = .server
    @State private var serverErrorAlertVisible: Bool = false
    /// This client is used while the user is unauthenticated. It has no token
    @State private var apiClient: APIClient?
    
    @State private var serverUrl: String?
    @State private var username: String?
    @State private var password: String?
    
    var body: some View {
        NavigationView {
            Group {
                switch currentState {
                case .server:
                    LoginFlowServer() { url in
                        serverUrl = url
                        currentState = .pinging
                    }
                case .pinging:
                    FullscreenLoadingIndicator(description: "Testing connection")
                        .task(pingServer)
                case .credentials:
                    LoginFlowCredentials() { username, password in
                        self.username = username
                        self.password = password
                        currentState = .processing
                    }
                case .processing:
                    FullscreenLoadingIndicator(description: "Generating token...")
                        .task(sendCredentials)
                }
            }
            .navigationTitle("Login")
            .alert(isPresented: $serverErrorAlertVisible) {
                Alert(title: Text(currentState == .credentials ? "Invalid credentials" : "Invalid response"), message: Text("Error while contacting your server"))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    @Sendable private func pingServer() async {
        do {
            apiClient = try APIClient(serverUrl: serverUrl!, token: nil)
            if try await apiClient?.request(APIResources.ping.get) != nil {
                return currentState = .credentials
            }
            
            throw APIError.invalidResponse
        } catch {
            serverErrorAlertVisible = true
            currentState = .server
        }
    }
    @Sendable private func sendCredentials() async {
        do {
            guard let loginResponse = try await apiClient?.request(APIResources.login.post(username: username!, password: password!)) else {
                throw APIError.invalidResponse
            }
            
            let user = User(context: viewContext)
            user.serverUrl = URL(string: serverUrl!)!
            user.username = loginResponse.user.username
            user.token = loginResponse.user.token
            user.lastActiveLibraryId = loginResponse.userDefaultLibraryId
            
            try viewContext.save()
            DispatchQueue.global(qos: .background).async {
                PersistenceController.shared.updateMediaProgressDatabase(loginResponse.user.mediaProgress)
            }
            callback()
        } catch {
            serverErrorAlertVisible = true
            currentState = .credentials
        }
    }
}

struct LoginViewInner_Previews: PreviewProvider {
    static var previews: some View {
        LoginViewInner() {
            print("Login flow finished")
        }
    }
}
