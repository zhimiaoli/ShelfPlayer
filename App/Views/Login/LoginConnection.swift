//
//  LoginFlowServerAdress.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI

extension LoginView {
    struct LoginFlowServer: View {
        @EnvironmentObject private var viewModel: LoginViewModel
        
        var body: some View {
            VStack {
                Form {
                    Section("Setup connection") {
                        TextField("Server-URL", text: $viewModel.serverUrl)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        Button {
                            viewModel.pingServer()
                        } label: {
                            Text("Continue")
                        }
                    }
                }
                .onSubmit(viewModel.pingServer)
            }
        }
    }
}
