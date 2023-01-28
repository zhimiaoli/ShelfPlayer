//
//  itemButtons.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

struct ItemButtons: View {
    var item: LibraryItem
    var colorScheme: ColorScheme
    
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    @State private var finished: Bool = false
    
    var body: some View {
        HStack {
            Button {
                globalViewModel.playItem(item: item)
            } label: {
                Label("Listen now", systemImage: "play.fill")
            }
            .buttonStyle(PlayNowButtonStyle(colorScheme: colorScheme))
            
            Button {
                
            } label: {
                Image(systemName: "arrow.down")
            }
            .buttonStyle(SecondaryButtonStyle(colorScheme: colorScheme, specialBackground: false))
            
            Button {
                Task {
                    let result = await item.toggleFinishedStatus()
                    if result {
                        finished.toggle()
                    }
                }
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(SecondaryButtonStyle(colorScheme: colorScheme, specialBackground: finished))
        }
        .foregroundColor(colorScheme == .light ? .black : .white)
        .onAppear {
            finished = PersistenceController.shared.getProgressByLibraryItem(item: item) == 1
        }
    }
}
