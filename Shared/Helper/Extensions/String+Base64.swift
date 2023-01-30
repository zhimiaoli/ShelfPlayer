//
//  String+Base64.swift
//  Books
//
//  Created by Rasmus Krämer on 23.01.23.
//

import Foundation

// https://stackoverflow.com/questions/29365145/how-can-i-encode-a-string-to-base64-in-swift
extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
