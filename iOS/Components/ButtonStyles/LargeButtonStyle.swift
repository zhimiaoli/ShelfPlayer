//
//  LargeButtonStyle.swift
//  Books
//
//  Created by Rasmus Krämer on 12.11.22.
//

import SwiftUI

struct LargeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .frame(width: 250)
            .foregroundColor(.white)
            .background(Color.accentColor)
            .font(.headline)
            .cornerRadius(7)
    }
}


struct LargeButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button {
            
        } label: {
            Text("Test")
        }
        .buttonStyle(LargeButtonStyle())
    }
}
