//
//  LocationDelegate.swift
//  iOS
//
//  Created by Rasmus Krämer on 30.01.24.
//

import Foundation
import CoreLocation

@Observable
class LocationDelegate: CLLocationManager {
    var authorized = false
    
    override init() {
        super.init()
        authorized = authorizationStatus == .authorizedWhenInUse
        requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("a")
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            authorized = true
            break
            
        case .restricted, .denied:
            authorized = false
            break
            
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
}
