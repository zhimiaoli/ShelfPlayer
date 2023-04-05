//
//  LineLimitView.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 13.02.23.
//

import SwiftUI

// https://stackoverflow.com/questions/75237993/how-do-i-know-whether-i-reached-the-text-linelimit-limit-in-swiftui
struct LineLimitView: View {
    let text: String
    let title: String
    let limit: Int
    
    @State var isExpanded = false
    @State var canBeExpanded = false
    
    var body: some View {
        VStack {
            Text(text)
                .lineLimit(limit)
                .background {
                    ViewThatFits(in: .vertical) {
                        Text(text)
                            .hidden()
                        
                        Color.clear
                            .onAppear {
                                canBeExpanded = true
                            }
                    }
                }
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
        }
        .sheet(isPresented: $isExpanded, content: {
            NavigationView {
                VStack {
                    Text(text)
                        .padding()
                    
                    Spacer()
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium, .large])
        })
    }
}