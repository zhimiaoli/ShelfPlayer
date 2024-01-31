//
//  AudiobookshelfClient.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 17.09.23.
//

import Foundation

public class AudiobookshelfClient {
    public private(set) var serverUrl: URL!
    public private(set) var localServerUrl: URL?
    
    public private(set) var token: String!
    
    public private(set) var clientVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    public private(set) var clientBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
    
    public private(set) var clientId: String
    static let defaults = ENABLE_ALL_FEATURES ? UserDefaults(suiteName: "group.io.rfk.shelfplayer")! : UserDefaults.standard
    
    init(serverUrl: URL!, localServerUrl: URL?, token: String!) {
        if !ENABLE_ALL_FEATURES {
            print("[WARNING] User data will not be stored in an app group")
        }
        
        self.serverUrl = serverUrl
        self.localServerUrl = localServerUrl
        self.token = token
        
        if let clientId = Self.defaults.string(forKey: "clientId") {
            self.clientId = clientId
        } else {
            clientId = String.random(length: 100)
            Self.defaults.set(clientId, forKey: "clientId")
        }
    }
}

public extension AudiobookshelfClient {
    var isAuthorized: Bool {
        self.token != nil
    }
    
    func setServerUrl(_ serverUrl: String) throws {
        guard let serverUrl = URL(string: serverUrl) else {
            throw AudiobookshelfClientError.invalidServerUrl
        }
        
        Self.defaults.set(serverUrl, forKey: "serverUrl")
        self.serverUrl = serverUrl
    }
    
    func setLocalServerUrl(_ serverUrl: String) async throws {
        guard let serverUrl = URL(string: serverUrl) else {
            throw AudiobookshelfClientError.invalidServerUrl
        }
        
        localServerUrl = serverUrl
        
        do {
            try await AudiobookshelfClient.shared.ping()
            Self.defaults.set(serverUrl, forKey: "localServerUrl")
        } catch {
            localServerUrl = nil
            throw AudiobookshelfClientError.invalidServerUrl
        }
    }
    
    func setToken(_ token: String) {
        Self.defaults.set(token, forKey: "token")
        self.token = token
    }
    
    func logout() {
        Self.defaults.set(nil, forKey: "token")
        exit(0)
    }
}

enum AudiobookshelfClientError: Error {
    case invalidServerUrl
    case invalidHttpBody
    case invalidResponse
    case missing
}

extension AudiobookshelfClient {
    public static let shared = AudiobookshelfClient(serverUrl: defaults.url(forKey: "serverUrl"), localServerUrl: defaults.url(forKey: "localServerUrl"), token: defaults.string(forKey: "token"))
}
