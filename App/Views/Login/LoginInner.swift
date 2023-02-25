//
//  LoginViewInner.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI

/// Manages wich login form is presented to the user
extension LoginView {
    struct LoginViewInner: View {
        @EnvironmentObject var viewModel: LoginViewModel
        
        var body: some View {
            NavigationStack {
                Group {
                    switch viewModel.currentState {
                    case .server:
                        LoginFlowServer()
                    case .pinging:
                        FullscreenLoadingIndicator(description: "Testing connection")
                    case .credentials:
                        LoginFlowCredentials()
                    case .processing:
                        FullscreenLoadingIndicator(description: "Generating token...")
                    case .done:
                        Text("This *should not happen*")
                    }
                }
                .navigationTitle("Login")
                .alert(isPresented: $viewModel.serverErrorAlertVisible) {
                    Alert(title: Text(viewModel.currentState == .credentials ? "Invalid credentials" : "Invalid response"), message: Text("Error while contacting your server"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
            }
        }
    }
}
