//
//  ChapterSeekSlider.swift
//  Books
//
//  Created by Rasmus Krämer on 30.01.23.
//

import SwiftUI

struct SeekSlider: View {
    var isBook: Bool
    
    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var playedPercentage: Double = 0
    @State private var chapter: PlayResponse.Chapter?
    
    @State private var buffering: Bool = true
    @State private var seekTarget: Double?
    @State private var seekSliderDragging: Bool = false
    @State private var useChapterView: Bool = PlayerHelper.getUseChapterView()
    
    var body: some View {
        HStack {
            Slider(percentage: $playedPercentage, dragging: $seekSliderDragging, onEnded: {
                if chapter != nil {
                    PlayerHelper.audioPlayer?.seek(to: (chapter?.start ?? 0) + seekTarget!)
                } else {
                    PlayerHelper.audioPlayer?.seek(to: seekTarget!)
                }
            })
        }
        .frame(height: 10)
        
        HStack {
            if !buffering {
                Text(TextHelper.formatTime(tourple: Date.secondsToHoursMinutesSeconds(Int(seekTarget ?? (currentTime.isInfinite || currentTime.isNaN ? 0 : currentTime))), forceHours: currentTime > 60 && duration > 3_600))
                    .font(.caption)
                    .frame(width: 45)
                    .padding(.leading, -5)
            } else {
                ProgressView()
                    .scaleEffect(0.5)
            }
            
            Spacer()
            Group {
                if let chapter = chapter {
                    Text(chapter.title)
                        .lineLimit(1)
                } else {
                    Text(TextHelper.formatRemainingTime(seconds: currentTime.isInfinite || currentTime.isNaN ? 0 : Int(duration - currentTime)))
                }
            }
            .font(.caption2)
            Spacer()
            
            Text(TextHelper.formatTime(tourple: Date.secondsToHoursMinutesSeconds(Int(duration)), forceHours: duration > 3_600))
                .font(.caption)
                .frame(width: 45)
                .padding(.trailing, -5)
        }
        .frame(height: 30)
        .padding(.top, seekSliderDragging ? -7 : -10)
        .animation(.easeInOut, value: seekSliderDragging)
        .foregroundColor(.primaryTransparent)
        .onReceive(timer) { _ in
            buffering = PlayerHelper.audioPlayer?.buffering ?? true
            
            let currentTime = PlayerHelper.audioPlayer?.getCurrentTime() ?? 0
            let duration = PlayerHelper.audioPlayer?.getTotalDuration() ?? 0
            
            if useChapterView && isBook, let chapter = getChapter(currentTime) {
                self.duration = chapter.end - chapter.start
                self.currentTime = self.duration - (chapter.end - currentTime)
                
                self.chapter = chapter
            } else {
                self.currentTime = currentTime
                self.duration = duration
            }
            
            if !seekSliderDragging {
                playedPercentage = (self.currentTime / self.duration) * 100
            }
        }
        .onReceive(NSNotification.PlayerSettingsUpdated, perform: { _ in
            useChapterView = PlayerHelper.getUseChapterView()
        })
         .onChange(of: playedPercentage, perform: { value in
             if !seekSliderDragging {
                 seekTarget = nil
                 return
             }
             
             let percentage = value / 100
             seekTarget = duration * percentage
         })
    }
    
    func getChapter(_ time: Double) -> PlayResponse.Chapter? {
        globalViewModel.currentPlaySession?.chapters.filter { $0.start <= time && $0.end > time }.first
    }
}
