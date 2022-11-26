//
//  ColorExtractor.swift
//  Books
//
//  Created by Rasmus Krämer on 26.11.22.
//

import Foundation
import UIKit

struct ImageHelper {
    public static func getImageUrl(id: String) -> URL {
        let user = PersistenceController.shared.getLoggedInUser()!
        return user.serverUrl!.appending(path: "/api/items").appending(path: id).appending(path: "cover").appending(queryItems: [URLQueryItem(name: "token", value: user.token)])
    }
    
    public static func getAverageColor(id: String) async -> (UIColor, Bool) {
        let image: UIImage?
        
        if let imageData: NSData = NSData(contentsOf: getImageUrl(id: id)) {
            image = UIImage(data: imageData as Data)
            
            if let image = image, let averageColor = image.averageColor {
                return (averageColor, averageColor.isLight() ?? false)
            }
        }
        
        return (UIColor.secondarySystemBackground, UIColor.secondarySystemBackground.isLight() ?? false)
    }
}
