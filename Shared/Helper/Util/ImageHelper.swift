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
}
