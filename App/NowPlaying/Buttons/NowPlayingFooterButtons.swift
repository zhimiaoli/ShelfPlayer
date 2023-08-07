//
//  NowPlayingFooterButtons.swift
//  Books
//
//  Created by Rasmus Krämer on 31.01.23.
//

import SwiftUI
import AVKit

struct NowPlayingFooterButtons: View {
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    @State var currentSpeed = PlayerHelper.audioPlayer?.desiredPlaybackRate ?? 0
    
    var body: some View {
        HStack {
            Menu {
                Button("0.25x") {
                    setPlaybackSpeed(0.25)
                }
                Button("0.5x") {
                    setPlaybackSpeed(0.5)
                }
                Button("0.75x") {
                    setPlaybackSpeed(0.75)
                }
                Button("1x") {
                    setPlaybackSpeed(1)
                }
                Button("1.25x") {
                    setPlaybackSpeed(1.25)
                }
                Button("1.5x") {
                    setPlaybackSpeed(1.5)
                }
                Button("1.75x") {
                    setPlaybackSpeed(1.75)
                }
                Button("2x") {
                    setPlaybackSpeed(2)
                }
            } label: {
                if currentSpeed == 1 {
                    Text("1x")
                } else if currentSpeed == 2 {
                    Text("2x")
                } else {
                    Text(String(currentSpeed)) + Text("x")
                }
            } primaryAction: {
                Haptics.shared.play(.light)
                
                currentSpeed += 0.25
                
                if currentSpeed > 2 {
                    currentSpeed = 0.25
                }
            }
            .frame(width: 75)
            .onChange(of: currentSpeed, perform: { speed in
                PlayerHelper.audioPlayer?.setPlaybackrate(speed)
            })
            .onReceive(NSNotification.PlayerRateChanged, perform: { _ in
                currentSpeed = PlayerHelper.audioPlayer?.desiredPlaybackRate ?? 0
            })
            Spacer()
            
            Group {
                if let chapters = globalViewModel.currentPlaySession?.chapters, chapters.count > 1 {
                    Menu {
                        ForEach(chapters, id: \.id) { chapter in
                            Button {
                                PlayerHelper.audioPlayer?.seek(to: chapter.start)
                            } label: {
                                Text(chapter.title)
                            }
                        }
                    } label: {
                        Image(systemName: "bookmark.fill")
                            .symbolRenderingMode(.monochrome)
                    }
                } else {
                    Image(systemName: "bookmark.fill")
                        .symbolRenderingMode(.monochrome)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 75)
            Spacer()
            
            HStack {
                AirPlayView()
                    .frame(width: 40)
            }
            .frame(width: 75)
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "moon.zzz.fill")
            }
            .frame(width: 75)
        }
        .fontDesign(.rounded)
        .bold()
        .foregroundColor(.primaryTransparent)
        .tint(.pink)
        .symbolRenderingMode(.multicolor)
        .frame(height: 25)
    }
    
    func setPlaybackSpeed(_ speed: Float) {
        Haptics.shared.play(.light)
        currentSpeed = speed
    }
}

struct AirPlayView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let routePickerView = AVRoutePickerView()
        routePickerView.backgroundColor = UIColor.clear
        routePickerView.activeTintColor = UIColor(Color.accentColor)
        routePickerView.tintColor = UIColor(Color.primaryTransparent)
        
        return routePickerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
