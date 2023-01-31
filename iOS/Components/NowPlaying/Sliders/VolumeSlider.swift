//
//  VolumeSlider.swift
//  Books
//
//  Created by Rasmus Krämer on 28.01.23.
//

import SwiftUI
import MediaPlayer

struct VolumeSlider: View {
    @State var volume: Double = Double(MPVolumeView.getVolume() * 100)
    @State var dragging: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: "speaker.fill")
                .onTapGesture {
                    volume = 0.0
                }
            Slider(percentage: $volume, dragging: $dragging)
            Image(systemName: "speaker.wave.3.fill")
                .onTapGesture {
                    volume = 100.0
                }
        }
        .dynamicTypeSize(dragging ? .xLarge : .medium)
        .animation(.easeInOut, value: dragging)
        .onChange(of: volume) { volume in
            MPVolumeView.setVolume(Float(volume / 100))
        }
    }
}

struct VolumeSlider_Previews: PreviewProvider {
    static var previews: some View {
        VolumeSlider()
    }
}
