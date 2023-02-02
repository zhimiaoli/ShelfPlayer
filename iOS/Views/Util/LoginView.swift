//
//  LoginView.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI

/// Login flow root view
struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel = LoginViewModel()
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    var body: some View {
        Group {
            VStack {
                if viewModel.currentState == .done {
                    FullscreenLoadingIndicator(description: "Processing")
                        .onAppear {
                            if let user = PersistenceController.shared.getLoggedInUser() {
                                globalViewModel.activeLibraryId = user.lastActiveLibraryId!
                                globalViewModel.token = user.token!
                                globalViewModel.loggedIn = true
                                globalViewModel.onlineStatus = .online
                            } else {
                                viewModel.currentState = .server
                            }
                        }
                } else {
                    Text("Welcome")
                        .font(.system(.title, design: .serif))
                        .padding(.bottom, 3)
                    Text("To start using the app please login")
                    
                    Button {
                        viewModel.loginSheetPresented.toggle()
                    } label: {
                        Text("Login")
                    }
                    .buttonStyle(LargeButtonStyle())
                    .padding()
                }
            }
            .sheet(isPresented: $viewModel.loginSheetPresented) {
                LoginViewInner()
            }
        }
        .environmentObject(viewModel)
    }
}

extension LoginView {
    /// View model used for the login flow
    class LoginViewModel: ObservableObject {
        @Published var serverUrl: String = ""
        @Published var username: String = ""
        @Published var password: String = ""
        
        @Published var loginSheetPresented: Bool = false
        @Published var currentState: LoginFlowState = .server
        @Published var serverErrorAlertVisible: Bool = false
        
        /// This client is used while the user is unauthenticated. It has no token
        private var apiClient: APIClient?
        
        /// Try to ping the server
        public func pingServer() {
            currentState = .pinging
            
            Task.detached {
                do {
                    self.apiClient = try APIClient(serverUrl: self.serverUrl, token: nil)
                    if try await self.apiClient?.request(APIResources.ping.get) != nil {
                        DispatchQueue.main.async {
                            self.currentState = .credentials
                        }
                        return
                    }
                    
                    throw APIError.invalidResponse
                } catch {
                    DispatchQueue.main.async {
                        self.serverErrorAlertVisible = true
                        self.currentState = .server
                    }
                }
            }
        }
        /// Request a token from the server
        public func sendCredentials() {
            currentState = .processing
            
            Task.detached {
                do {
                    guard let loginResponse = try await self.apiClient?.request(APIResources.login.post(username: self.username, password: self.password)) else {
                        throw APIError.invalidResponse
                    }
                    
                    let viewContext = PersistenceController.shared.container.viewContext
                    let user = User(context: viewContext)
                    
                    user.serverUrl = URL(string: self.serverUrl)!
                    user.username = loginResponse.user.username
                    user.token = loginResponse.user.token
                    user.lastActiveLibraryId = loginResponse.userDefaultLibraryId
                    
                    try viewContext.save()
                    DispatchQueue.global(qos: .background).async {
                        PersistenceController.shared.updateMediaProgressDatabase(loginResponse.user.mediaProgress)
                    }
                    
                    DispatchQueue.main.async {
                        self.currentState = .done
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.serverErrorAlertVisible = true
                        self.currentState = .credentials
                    }
                }
            }
        }
    }
    
    /// Current state of the login flow
    enum LoginFlowState {
        case server
        case pinging
        case credentials
        case processing
        case done
    }
}
