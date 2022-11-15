//
//  LoginFlowServerAdress.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI

struct LoginFlowServer: View {
    @State private var serverUrl: String = "https://"
    var callback: ((String) -> Void)
    
    var body: some View {
        VStack {
            Form {
                Section("Setup connection") {
                    TextField("Server-URL", text: $serverUrl)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    Button {
                        callback(serverUrl)
                    } label: {
                        Text("Continue")
                    }
                }
            }
        }
    }
}

struct LoginFlowServer_Previews: PreviewProvider {
    static var previews: some View {
        LoginFlowServer(callback: { serverUrl in
            print("URL: \(serverUrl)")
        })
    }
}
