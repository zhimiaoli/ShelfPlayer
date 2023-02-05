//
//  MPVolumeView+Volume.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import MediaPlayer

// https://stackoverflow.com/questions/37873962/setting-the-system-volume-in-swift-under-ios
extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}
