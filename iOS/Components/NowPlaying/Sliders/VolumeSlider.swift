//
//  VolumeSlider.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI
import MediaPlayer

struct VolumeSlider: View {
    @State var volume: Float = MPVolumeView.getVolume() * 100
    
    var body: some View {
        HStack {
            Image(systemName: "speaker.fill")
                .onTapGesture {
                    volume = 0.0
                }
            Slider(percentage: $volume)
                .frame(height: 7)
            Image(systemName: "speaker.wave.3.fill")
                .onTapGesture {
                    volume = 100.0
                }
        }
        .onChange(of: volume) { volume in
            MPVolumeView.setVolume(volume / 100)
        }
    }
}

struct VolumeSlider_Previews: PreviewProvider {
    static var previews: some View {
        VolumeSlider()
    }
}
