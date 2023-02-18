//
//  LibraryItem+Image.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 18.02.23.
//

import Foundation
import UIKit

extension LibraryItem {
    public func getAverageColor() async -> (UIColor, Bool) {
        let image: UIImage?
        
        if let url = cover {
            if let imageData: NSData = NSData(contentsOf: url) {
                image = UIImage(data: imageData as Data)
                
                if let image = image, let averageColor = image.averageColor {
                    return (averageColor, averageColor.isLight() ?? false)
                }
            }
        }
        
        return (UIColor.secondarySystemBackground, UIColor.secondarySystemBackground.isLight() ?? false)
    }
    
    public func setUseBackgroundImage(_ use: Bool) {
        PersistenceController.shared.setKey("podcast.\(id).useBackgroundImage", value: use.description)
    }
    public func getUseBackgroundImage() -> Bool {
        PersistenceController.shared.getBoolValue(key: "podcast.\(id).useBackgroundImage", defaultValue: false)
    }
}
