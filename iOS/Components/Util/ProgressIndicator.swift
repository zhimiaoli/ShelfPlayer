//
//  ProgressIndicator.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct ProgressIndicator: View {
    var completedPercentage: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.5), lineWidth: 3)
            Circle()
                .trim(from: 0, to: CGFloat(completedPercentage))
                .stroke(Color.primary, lineWidth: 3)
        }
        .rotationEffect(.degrees(-90))
    }
}

struct ProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ProgressIndicator(completedPercentage: 0.5)
    }
}
