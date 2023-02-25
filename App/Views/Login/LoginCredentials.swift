//
//  LoginFlowCredentials.swift
//  Books
//
//  Created by Rasmus Krämer on 13.11.22.
//

import SwiftUI

extension LoginView {
    struct LoginFlowCredentials: View {
        @EnvironmentObject var viewModel: LoginViewModel
        
        var body: some View {
            VStack {
                Form {
                    Section("Credentials") {
                        TextField("Username", text: $viewModel.username)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        SecureField("Password", text: $viewModel.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        Button {
                            viewModel.sendCredentials()
                        } label: {
                            Text("Continue")
                        }
                    }
                }
                .onSubmit(viewModel.sendCredentials)
            }
        }
    }
}
