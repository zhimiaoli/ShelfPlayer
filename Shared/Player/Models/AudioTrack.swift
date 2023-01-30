//
//  AudioTrack.swift
//  Books
//
//  Created by Rasmus Krämer on 30.01.23.
//

import Foundation

struct AudioTrack: Codable {
    let index: Int?
    let startOffset: Double
    let duration: Double
    let contentUrl: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.index = try container.decodeIfPresent(Int.self, forKey: .index)
        self.contentUrl = try container.decode(String.self, forKey: .contentUrl)
        
        do {
            self.startOffset = try container.decode(Double.self, forKey: .startOffset)
        } catch {
            if let parsed = try? container.decode(Double.self, forKey: .startOffset) {
                self.startOffset = Double(parsed)
            } else {
                self.startOffset = 0
            }
        }
        do {
            self.duration = try container.decode(Double.self, forKey: .duration)
        } catch {
            if let parsed = try? container.decode(Double.self, forKey: .duration) {
                self.duration = Double(parsed)
            } else {
                self.duration = 0
            }
        }
    }
}
