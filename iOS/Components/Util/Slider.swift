//
//  Slider.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

struct Slider: View {
    @Binding var percentage: Float

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.7))
                Rectangle()
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: geometry.size.width * CGFloat(self.percentage / 100))
            }
            .cornerRadius(7)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    self.percentage = min(max(0, Float(value.location.x / geometry.size.width * 100)), 100)
                }))
        }
    }
}

struct Slider_Previews: PreviewProvider {
    @State static var percentage: Float = 50
    
    static var previews: some View {
        VStack {
            Slider(percentage: $percentage)
                .frame(height: 7)
                .padding(.horizontal)
            Text(String(percentage))
        }
    }
}
