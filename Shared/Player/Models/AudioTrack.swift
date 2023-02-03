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
    
    let metadata: AudioTrackMetadata?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.index = try container.decodeIfPresent(Int.self, forKey: .index)
        self.contentUrl = try container.decode(String.self, forKey: .contentUrl)
        self.metadata = try container.decode(AudioTrackMetadata.self, forKey: .metadata)
        
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
    
    init(index: Int?, startOffset: Double, duration: Double, contentUrl: String, metadata: AudioTrackMetadata?) {
        self.index = index
        self.startOffset = startOffset
        self.duration = duration
        self.contentUrl = contentUrl
        self.metadata = metadata
    }
    
    struct AudioTrackMetadata: Codable {
        let ext: String?
    }
}
