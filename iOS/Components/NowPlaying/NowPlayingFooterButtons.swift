//
//  NowPlayingFooterButtons.swift
//  Books
//
//  Created by Rasmus Krämer on 31.01.23.
//

import SwiftUI
import AVKit

struct NowPlayingFooterButtons: View {
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    @State private var currentSpeed = PlayerHelper.audioPlayer?.desiredPlaybackRate ?? 0
    
    var body: some View {
        HStack {
            Button {
                currentSpeed += 0.25
                
                if currentSpeed > 2 {
                    currentSpeed = 0.25
                }
            } label: {
                if currentSpeed == 1 {
                    Text("1x")
                } else if currentSpeed == 2 {
                    Text("2x")
                } else {
                    Text(String(currentSpeed)) + Text("x")
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
            
            Menu {
                ForEach(globalViewModel.currentPlaySession!.chapters, id: \.id) { chapter in
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
        .font(.system(.body, design: .rounded))
        .bold()
        .foregroundColor(.primaryTransparent)
        .tint(.pink)
        .symbolRenderingMode(.multicolor)
        .frame(height: 25)
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
