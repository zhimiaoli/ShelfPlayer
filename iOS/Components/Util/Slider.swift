//
//  Slider.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

struct Slider: View {
    @Binding var percentage: Double
    @Binding var dragging: Bool
    
    var onEnded: (() -> Void)? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.5) )
                Rectangle()
                    .foregroundColor(dragging ? .primary : .primary.opacity(0.8))
                    .frame(width: geometry.size.width * CGFloat(self.percentage / 100))
            }
            .cornerRadius(7)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    percentage = min(max(0, Double(value.location.x / geometry.size.width * 100)), 100)
                    dragging = true
                }
                .onEnded { _ in
                    dragging = false
                    onEnded?()
                }
            )
        }
        .frame(height: dragging ? 10 : 7)
        .animation(.easeInOut, value: dragging)
    }
}

struct Slider_Previews: PreviewProvider {
    @State static var percentage: Double = 50
    @State static var dragging: Bool = false
    
    static var previews: some View {
        VStack {
            Slider(percentage: $percentage, dragging: $dragging)
                .padding(.horizontal)
            Text(String(percentage))
        }
    }
}
