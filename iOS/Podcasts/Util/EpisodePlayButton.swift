//
//  EpisodePlayButton.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 08.10.23.
//

import SwiftUI
import SPBaseKit
import SPOfflineKit
import SPPlaybackKit

struct EpisodePlayButton: View {
    let episode: Episode
    var highlighted: Bool = false
    
    @State var progress: OfflineProgress?
    @State var playing: Bool? = nil
    
    var body: some View {
        Button {
            episode.startPlayback()
        } label: {
            ButtonText(episode: episode, highlighted: highlighted, playing: $playing, progress: $progress)
                .opacity(highlighted ? 0 : 1)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(highlighted ? .white : .secondary.opacity(0.25))
                .foregroundStyle(highlighted ? .black : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 10000))
                .reverseMask {
                    if highlighted {
                        ButtonText(episode: episode, highlighted: highlighted, playing: $playing, progress: $progress)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: OfflineManager.progressCreatedNotification), perform: { _ in
                    fetchProgress()
                })
                .onReceive(NotificationCenter.default.publisher(for: AudioPlayer.startStopNotification), perform: { _ in
                    checkPlaying()
                })
                .onReceive(NotificationCenter.default.publisher(for: AudioPlayer.playPauseNotification), perform: { _ in
                    checkPlaying()
                })
                .onAppear {
                    fetchProgress()
                    checkPlaying()
                }
                .onChange(of: episode) {
                    fetchProgress()
                    checkPlaying()
                }
        }
        .buttonStyle(.plain)
    }
}

extension EpisodePlayButton {
    struct ButtonText: View {
        @Environment(\.colorScheme) var colorScheme
        
        let episode: Episode
        let highlighted: Bool
        
        @Binding var playing: Bool?
        @Binding var progress: OfflineProgress?
        
        var body: some View {
            HStack(spacing: 6) {
                if let playing = playing {
                    Image(systemName: playing == true ? "waveform" : "pause.fill")
                        .symbolEffect(.variableColor.iterative, isActive: playing == true)
                } else {
                    Image(systemName: "play.fill")
                }
                
                if let progress = progress {
                    if progress.progress >= 1 {
                        Text("progress.completed")
                            .font(.caption.smallCaps())
                            .bold()
                    } else {
                        if progress.progress > 0 {
                            Rectangle()
                                .foregroundStyle(.gray.opacity(0.25))
                                .overlay(alignment: .leading) {
                                    Rectangle()
                                        .frame(width: max(50 * progress.progress, 5))
                                        .foregroundStyle(highlighted ? .black : colorScheme == .light ? .black : .white)
                                }
                                .frame(width: 50, height: 7)
                                .clipShape(RoundedRectangle(cornerRadius: 10000))
                        }
                        
                        Text((progress.duration - progress.currentTime).numericTimeLeft())
                    }
                } else {
                    Text(episode.duration.numericTimeLeft())
                }
            }
            .font(.caption)
        }
    }
}

extension EpisodePlayButton {
    private func fetchProgress() {
        Task.detached {
            let progress = await OfflineManager.shared.getProgressEntity(item: episode)
            withAnimation {
                self.progress = progress
            }
        }
    }
    
    private func checkPlaying() {
        withAnimation {
            if episode == AudioPlayer.shared.item {
                playing = AudioPlayer.shared.isPlaying()
            } else {
                playing = nil
            }
        }
    }
}

#Preview {
    Rectangle()
        .foregroundStyle(.black)
        .overlay {
            EpisodePlayButton(episode: Episode.fixture)
        }
}

#Preview {
    Rectangle()
        .foregroundStyle(.black)
        .overlay {
            EpisodePlayButton(episode: Episode.fixture, highlighted: true)
        }
}