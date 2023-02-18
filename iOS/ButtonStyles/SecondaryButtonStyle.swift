//
//  SecondaryButtonStyle.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    let colorScheme: ColorScheme
    var backgroundColor: Color? = nil
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.bold)
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background {
                backgroundColor ?? (colorScheme == .light ? .white : .black)
            }
            .foregroundColor(colorScheme == .light ? .black : .white)
            .cornerRadius(7)
    }
}
