//
//  PlayNowButtonStyle.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import SwiftUI

struct PlayNowButtonStyle: ButtonStyle {
    @EnvironmentObject var globalViewModel: GlobalViewModel
    let colorScheme: ColorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontDesign(.libraryFontDesign(globalViewModel.activeLibraryType))
            .fontWeight(.bold)
            .padding(.vertical, 12)
            .padding(.horizontal, 30)
            .background(colorScheme == .light ? .white : .black)
            .foregroundColor(colorScheme == .light ? .black : .white)
            .cornerRadius(7)
    }
}
