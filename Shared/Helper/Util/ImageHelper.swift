//
//  ColorExtractor.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import Foundation
import UIKit

struct ImageHelper {
    public static func getAverageColor(item: LibraryItem) async -> (UIColor, Bool) {
        let image: UIImage?
        
        if let url = item.cover {
            if let imageData: NSData = NSData(contentsOf: url) {
                image = UIImage(data: imageData as Data)
                
                if let image = image, let averageColor = image.averageColor {
                    return (averageColor, averageColor.isLight() ?? false)
                }
            }
        }
        
        return (UIColor.secondarySystemBackground, UIColor.secondarySystemBackground.isLight() ?? false)
    }
    
    public static func setUseBackgroundImage(_ use: Bool, podcastId: String) {
        PersistenceController.shared.setKey("podcast.\(podcastId).useBackgroundImage", value: use.description)
    }
    public static func getUseBackgroundImage(podcastId: String) -> Bool {
        let value: String = PersistenceController.shared.getValue(key: "podcast.\(podcastId).useBackgroundImage") ?? "false"
        return Bool(value) ?? false
    }
}
