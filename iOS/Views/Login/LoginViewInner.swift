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

struct LoginViewInner: View {
    @Environment(\.managedObjectContext) private var viewContext
    var callback: (() -> Void)
    
    @State private var currentState: LoginFlowState = .server
    @State private var serverErrorAlertVisible: Bool = false
    @State private var apiClient: APIClient?
    
    @State private var serverUrl: String?
    @State private var username: String?
    @State private var password: String?
    
    var body: some View {
        NavigationView {
            Group {
                if currentState == .server {
                    LoginFlowServer() { url in
                        serverUrl = url
                        currentState = .pinging
                    }
                } else if currentState == .pinging {
                    FullscreenLoadingIndicator(description: "Testing connection")
                        .task(pingServer)
                } else if currentState == .credentials {
                    LoginFlowCredentials() { username, password in
                        self.username = username
                        self.password = password
                        currentState = .processing
                    }
                } else if currentState == .processing {
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
            guard let pingResponse = try await apiClient?.request(APIResources.ping.get) else {
                throw APIError.invalidResponse
            }
            if pingResponse.success != true {
                throw APIError.invalidResponse
            }
            
            currentState = .credentials
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
            
            print("\(user.token) f (\(username))")
            
            try viewContext.save()
            callback()
        } catch {
            serverErrorAlertVisible = true
            currentState = .credentials
            
            print(error)
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
