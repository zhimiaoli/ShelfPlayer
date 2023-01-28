//
//  View+Namespace.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI

// https://stackoverflow.com/questions/63130663/how-to-pass-namespace-to-multiple-views-in-swiftui
struct NamespaceEnvironmentKey: EnvironmentKey {
    static var defaultValue: Namespace.ID = Namespace().wrappedValue
}

extension EnvironmentValues {
    var namespace: Namespace.ID {
        get { self[NamespaceEnvironmentKey.self] }
        set { self[NamespaceEnvironmentKey.self] = newValue }
    }
}

extension View {
    func namespace(_ value: Namespace.ID) -> some View {
        environment(\.namespace, value)
    }
}
