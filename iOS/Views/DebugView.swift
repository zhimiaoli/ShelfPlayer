//
//  DebugView.swift
//  Books
//
//  Created by Rasmus Krämer on 24.11.22.
//

import SwiftUI

struct DebugView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id, order: .reverse)]) private var cachedMediaProgresses: FetchedResults<CachedMediaProgress>
    
    var body: some View {
        List {
            Button {
                NotificationCenter.default.post(name: .logout, object: nil)
            } label: {
                Text("Logout")
            }
            
            ForEach(cachedMediaProgresses) { progress in
                Text(progress.id!)
            }
        }
        .tabItem {
            Label("Debug", systemImage: "gear.circle.fill")
        }
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}
