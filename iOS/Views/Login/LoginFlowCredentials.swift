//
//  LoginFlowCredentials.swift
//  Books
//
//  Created by Rasmus Krämer on 13.11.22.
//

import SwiftUI

struct LoginFlowCredentials: View {
    @State private var username: String = ""
    @State private var password: String = ""
    var callback: ((String, String) -> Void)
    
    var body: some View {
        VStack {
            Form {
                Section("Credentials") {
                    TextField("Username", text: $username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    Button {
                        callback(username, password)
                    } label: {
                        Text("Continue")
                    }
                }
            }
        }
    }
}

struct LoginFlowCredentials_Previews: PreviewProvider {
    static var previews: some View {
        LoginFlowCredentials(callback: { username, password in
            print("username: \(username) | password: \(password)")
        })
    }
}
