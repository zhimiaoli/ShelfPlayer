//
//  AuthorizationSubsystem.swift
//  ShelfPlayerKit
//
//  Created by Rasmus Krämer on 23.12.24.
//

import Foundation
import OSLog
import CryptoKit
import SwiftData
import RFNetwork
import RFNotifications

typealias DiscoveredConnection = SchemaV2.PersistedDiscoveredConnection

public let ABSClient = APIClientStore(timeout: 90) { connectionID in
    guard let connection = await PersistenceManager.shared.authorization[connectionID] else {
        throw PersistenceError.serverNotFound
    }
    
    let authorizationHeader = HTTPHeader(key: "Authorization", value: "Bearer \(connection.token)")
    
    return (connection.host, connection.headers + [authorizationHeader])
}

extension PersistenceManager {
    @ModelActor
    public final actor AuthorizationSubsystem: Sendable {
        private let service = "io.rfk.shelfPlayer.credentials" as CFString
        private let logger = Logger(subsystem: "io.rfk.shelfPlayerKit", category: "Authorization")
        
        private(set) public var connections = [ItemIdentifier.ConnectionID: Connection]()
        
        public struct KnownConnection: Sendable, Identifiable, Equatable {
            public let id: String
            
            public let host: URL
            public let username: String
        }
    }
}

public extension PersistenceManager.AuthorizationSubsystem {
    var knownConnections: [KnownConnection] {
        get async {
            var descriptor = FetchDescriptor<DiscoveredConnection>()
            descriptor.fetchLimit = 100
            
            do {
                return try modelContext.fetch(descriptor).map { .init(id: UUID().uuidString, host: $0.host, username: $0.user) }
            } catch {
                return []
            }
        }
    }
    
    func fetchConnections() throws {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrSynchronizable: kSecAttrSynchronizableAny,
            
            kSecAttrService: service,
            
            kSecReturnAttributes: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitAll,
        ] as! [String: Any] as CFDictionary
        
        var items: CFTypeRef?
        let status = SecItemCopyMatching(query, &items)
        
        guard status != errSecItemNotFound else {
            logger.info("No connections found in keychain")
            
            connections.removeAll()
            RFNotification[.connectionsChanged].dispatch(payload: connections)
            
            return
        }
        
        guard status == errSecSuccess, let items = items as? [[String: Any]] else {
            logger.error("Error retrieving connections from keychain: \(SecCopyErrorMessageString(status, nil))")
            throw PersistenceError.keychainRetrieveFailed
        }
        
        var existing = Array(connections.keys)
        
        for item in items {
            do {
                guard let connectionID = item[kSecAttrAccount as String] as? String else {
                    continue
                }
                
                if let index = existing.firstIndex(of: connectionID) {
                    existing.remove(at: index)
                }
                
                connections[connectionID] = try fetchConnection(connectionID)
            } catch {
                logger.fault("Error decoding connection from keychain: \(error).")
                continue
            }
        }
        
        for connectionID in existing {
            connections[connectionID] = nil
        }
        
        RFNotification[.connectionsChanged].dispatch(payload: connections)
    }
    
    func fetchConnection(_ connectionID: ItemIdentifier.ConnectionID) throws -> Connection {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrSynchronizable: kSecAttrSynchronizableAny,
            
            kSecAttrService: service,
            kSecAttrAccount: connectionID,
            
            kSecReturnData: kCFBooleanTrue as Any,
        ]
        
        var data: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &data)
        
        guard status == errSecSuccess, let data = data as? Data else {
            logger.fault("Error retrieving connection data from keychain: \(SecCopyErrorMessageString(status, nil))")
            throw PersistenceError.keychainRetrieveFailed
        }
        
        return try JSONDecoder().decode(Connection.self, from: data)
    }
    
    func addConnection(_ connection: Connection) throws {
        do {
            let discovered = DiscoveredConnection(connectionID: connection.id, host: connection.host, user: connection.user)
            
            modelContext.insert(discovered)
            try modelContext.save()
        } catch {
            logger.error("Failed to save discovered connection: \(error)")
        }
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrSynchronizable: kCFBooleanTrue as Any,
            
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            
            kSecAttrService: service,
            kSecAttrAccount: connection.id as CFString,
            
            kSecValueData: try JSONEncoder().encode(connection) as CFData,
        ] as! [String: Any] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        
        guard status == errSecSuccess else {
            logger.error("Error adding connection to keychain: \(SecCopyErrorMessageString(status, nil))")
            throw PersistenceError.keychainInsertFailed
        }
        
        try fetchConnections()
    }
    
    func updateConnection(_ connectionID: ItemIdentifier.ConnectionID, headers: [HTTPHeader]) throws {
        let connection = try fetchConnection(connectionID)
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrSynchronizable: kCFBooleanTrue as Any,
            
            kSecAttrService: service,
            kSecAttrAccount: connectionID as CFString,
        ] as! [String: Any] as CFDictionary
        
        let updated = Connection(host: connection.host, user: connection.user, token: connection.token, headers: headers)
        
        SecItemUpdate(query, [
            kSecValueData: try JSONEncoder().encode(updated) as CFData,
        ] as! [String: Any] as CFDictionary)
        
        Task {
            await ABSClient.invalidate(connectionID)
        }
        
        try fetchConnections()
    }
    
    func remove(connectionID: ItemIdentifier.ConnectionID) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrSynchronizable: kSecAttrSynchronizableAny,
            
            kSecAttrService: service,
            kSecAttrAccount: connectionID,
        ] as! [String: Any] as CFDictionary
        
        let status = SecItemDelete(query)
        
        if status != errSecSuccess {
            logger.error("Error removing connection from keychain: \(SecCopyErrorMessageString(status, nil))")
        }
        
        try? fetchConnections()
    }
    
    func reset() async {
        for (connectionID, _) in connections {
            await PersistenceManager.shared.remove(connectionID: connectionID)
        }
        
        SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrSynchronizable: kSecAttrSynchronizableAny,
        ] as CFDictionary)
        
        do {
            try modelContext.delete(model: DiscoveredConnection.self)
            try modelContext.save()
            
            try fetchConnections()
        } catch {
            logger.error("Failed to reset authorization subsystem: \(error)")
        }
    }
    
    subscript(_ id: ItemIdentifier.ConnectionID) -> Connection? {
        connections[id]
    }
}
