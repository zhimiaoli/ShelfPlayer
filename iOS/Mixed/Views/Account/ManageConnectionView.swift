//
//  ManageConnectionView.swift
//  iOS
//
//  Created by Rasmus Krämer on 30.01.24.
//

import SwiftUI
import SPBase
import SPOffline
import SPOfflineExtended
import CoreLocation

struct ManageConnectionView: View {
    let locationDelegate = LocationDelegate()
    
    @State var addLocalServerAvailable = false
    
    @State var localServer = ""
    @State var serverValid = false
    
    var body: some View {
        List {
            Section {
                Button(role: .destructive) {
                    OfflineManager.shared.deleteProgressEntities()
                    AudiobookshelfClient.shared.logout()
                } label: {
                    Text("account.logout")
                }
            } footer: {
                Text("account.logout.disclaimer")
            }
            
            Section {
                if CLLocationManager.headingAvailable() {
                    if locationDelegate.authorized {
                        Text("a")
                            .onAppear {
                                addLocalServerAvailable = true
                            }
                    } else {
                        Button {
                            
                        } label: {
                            Text("account.localServer.unauthorized")
                        }
                    }
                } else {
                    Text("account.localServer.unavailable")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("account.localServer.heading")
            } footer: {
                Text("account.localServer.footer")
            }
                
            if addLocalServerAvailable {
                Section {
                    TextField("account.localServer.server", text: $localServer)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: localServer) {
                            serverValid = false
                        }
                    
                    Button {
                        // AudiobookshelfClient.shared.ping()
                    } label: {
                        Text("account.localServer.verify")
                    }
                }
            }
            
            
            Section("account.server") {
                Text(AudiobookshelfClient.shared.token)
                Text(AudiobookshelfClient.shared.serverUrl.absoluteString)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ManageConnectionView()
}
