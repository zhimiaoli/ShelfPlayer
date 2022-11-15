//
//  LoginView.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI

struct LoginView: View {
    @State private var loginSheetPresented = false
    
    var callback: (() -> Void)
    
    var body: some View {
        VStack {
            Text("Welcome")
                .font(.system(.title, design: .serif))
                .padding(.bottom, 3)
            Text("To start using the app please login")
            
            Button {
                loginSheetPresented.toggle()
            } label: {
                Text("Login")
            }
            .buttonStyle(LargeButtonStyle())
            .padding()
        }
        .sheet(isPresented: $loginSheetPresented) {
            LoginViewInner(callback: callback)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView() {
            print("Login flow finished")
        }
    }
}
