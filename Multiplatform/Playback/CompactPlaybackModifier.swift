//
//  CompactPlaybackModifier.swift
//  Multiplatform
//
//  Created by Rasmus Krämer on 25.02.25.
//

import SwiftUI
import ShelfPlayback

struct CompactPlaybackModifier: ViewModifier {
    @Environment(\.playbackBottomOffset) private var playbackBottomOffset
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    @Environment(PlaybackViewModel.self) private var viewModel
    @Environment(Satellite.self) private var satellite
    
    static let height: CGFloat = 56
    
    let ready: Bool
    
    private var pushAmount: CGFloat {
        viewModel.pushAmount
    }
    
    func body(content: Content) -> some View {
        if ready && horizontalSizeClass == .compact {
            GeometryReader { geometryProxy in
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(.black)
                    
                    content
                        .allowsHitTesting(!viewModel.isExpanded)
                        .overlay {
                            Color.white.opacity(min(0.1, (1 - viewModel.pushAmount)))
                                .animation(.smooth(duration: 0.4), value: viewModel.isExpanded)
                        }
                        .scaleEffect(pushAmount, anchor: .center)
                        .mask(alignment: .center) {
                            let totalWidth = geometryProxy.size.width + geometryProxy.safeAreaInsets.leading + geometryProxy.safeAreaInsets.trailing
                            let width = totalWidth * viewModel.pushAmount
                            let leadingOffset = (totalWidth - width) / 2
                            
                            RoundedRectangle(cornerRadius: satellite.isNowPlayingVisible && !satellite.isSheetPresented ? viewModel.pushContainerCornerRadius(leadingOffset: leadingOffset) : 0, style: .continuous)
                                .fill(.black)
                                .frame(width: width,
                                       height: (geometryProxy.size.height + geometryProxy.safeAreaInsets.top + geometryProxy.safeAreaInsets.bottom) * viewModel.pushAmount)
                        }
                        .animation(.smooth, value: viewModel.pushAmount)
                        .accessibilityHidden(viewModel.isExpanded)
                            
                    if satellite.isNowPlayingVisible {
                        ZStack {
                            // Background
                            ZStack {
                                // Prevent content from shining through
                                if viewModel.isExpanded {
                                    Rectangle()
                                        #if DEBUG && false
                                            .foregroundStyle(.background.opacity(0.2))
                                        #else
                                            .foregroundStyle(.background)
                                        #endif
                                        .transition(.opacity)
                                        .transaction {
                                            if !viewModel.isExpanded {
                                                $0.animation = .smooth.delay(0.6)
                                            }
                                        }
                                }
                                
                                // Now playing bar background
                                Rectangle()
                                    .foregroundStyle(.regularMaterial)
                                    .opacity(viewModel.isExpanded ? 0 : 1)
                                
                                // Now playing view background
                                Group {
                                    if colorScheme == .dark {
                                        Rectangle()
                                            .foregroundStyle(.background.secondary)
                                    } else {
                                        Rectangle()
                                        #if DEBUG && false
                                            .foregroundStyle(.background.opacity(0.2))
                                        #else
                                            .foregroundStyle(.background)
                                        #endif
                                    }
                                }
                                .opacity(viewModel.isExpanded ? 1 : 0)
                                .animation(.smooth(duration: 0.1), value: viewModel.isExpanded)
                            }
                            .allowsHitTesting(false)
                            
                            // Drag gesture catcher
                            if viewModel.isExpanded {
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .contentShape(.rect)
                                    .modifier(PlaybackDragGestureCatcher(active: true))
                            }
                            
                            // Foreground
                            ZStack(alignment: .top) {
                                CollapsedForeground()
                                    .opacity(viewModel.isExpanded ? 0 : 1)
                                    .universalContentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .highPriorityGesture(DragGesture()
                                        .onChanged {
                                            if $0.translation.height < -100 || $0.velocity.height < -2000 {
                                                viewModel.isExpanded = true
                                            }
                                        }
                                    )
                                    .contextMenu {
                                        PlaybackMenuActions()
                                    } preview: {
                                        if let currentItem = satellite.nowPlayingItem {
                                            PlayableItemContextMenuPreview(item: currentItem)
                                        }
                                    }
                                    .allowsHitTesting(!viewModel.isExpanded)
                                    .accessibilityHidden(viewModel.isExpanded)
                                
                                CompactExpandedForeground(height: geometryProxy.size.height, safeAreTopInset: geometryProxy.safeAreaInsets.top, safeAreBottomInset: geometryProxy.safeAreaInsets.bottom)
                                    .allowsHitTesting(viewModel.isExpanded)
                                    .accessibilityHidden(!viewModel.isExpanded)
                            }
                        }
                        .frame(height: viewModel.isExpanded ? nil : Self.height)
                        .mask {
                            VStack(spacing: 0) {
                                UnevenRoundedRectangle(topLeadingRadius: viewModel.backgroundCornerRadius,
                                                       topTrailingRadius: viewModel.backgroundCornerRadius,
                                                       style: .continuous)
                                .frame(maxHeight: 60)
                                
                                // The padding prevents the mask from cutting lines in the background
                                // during the transformation. They are caused by the `spring` animation.
                                Rectangle()
                                    .padding(.vertical, -2)
                                
                                UnevenRoundedRectangle(bottomLeadingRadius: viewModel.backgroundCornerRadius,
                                                       bottomTrailingRadius: viewModel.backgroundCornerRadius,
                                                       style: .continuous)
                                .frame(maxHeight: 60)
                            }
                        }
                        .shadow(color: viewModel.isExpanded ? .clear : .black.opacity(0.2), radius: 8)
                        .padding(.horizontal, viewModel.isExpanded ? 0 : 12)
                        .padding(.bottom, viewModel.isExpanded ? 0 : geometryProxy.safeAreaInsets.bottom + playbackBottomOffset)
                        .offset(x: 0, y: viewModel.dragOffset)
                        .toolbarBackground(.hidden, for: .tabBar)
                        .animation(.snappy(duration: 0.6), value: viewModel.isExpanded)
                        .sensoryFeedback(.selection, trigger: viewModel.isQueueVisible)
                    }
                    
                }
                .frame(width: geometryProxy.size.width + geometryProxy.safeAreaInsets.leading + geometryProxy.safeAreaInsets.trailing,
                       height: geometryProxy.size.height + geometryProxy.safeAreaInsets.top + geometryProxy.safeAreaInsets.bottom)
                .ignoresSafeArea()
            }
        } else {
            content
        }
    }
}

struct CompactExpandedForeground: View {
    @Environment(PlaybackViewModel.self) private var viewModel
    @Environment(Satellite.self) private var satellite
    @Environment(\.namespace) private var namespace
    
    let height: CGFloat
    let safeAreTopInset: CGFloat
    let safeAreBottomInset: CGFloat
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {
            if viewModel.isExpanded {
                Rectangle()
                    .frame(height: safeAreTopInset)
                    .hidden()
                
                Spacer(minLength: 12)
                
                if !viewModel.isQueueVisible {
                    ItemImage(itemID: satellite.nowPlayingItemID, size: .large, aspectRatio: .none, contrastConfiguration: nil)
                        .id(satellite.nowPlayingItemID)
                        .padding(.horizontal, -8)
                        .shadow(color: .black.opacity(0.4), radius: 20)
                        .matchedGeometryEffect(id: "image", in: namespace!, properties: .frame, anchor: viewModel.isExpanded ? .topLeading : .topTrailing)
                        .scaleEffect(satellite.isPlaying ? 1 : 0.8)
                        .animation(.spring(duration: 0.3, bounce: 0.6), value: satellite.isPlaying)
                        .modifier(PlaybackDragGestureCatcher(active: true))
                    
                    Spacer(minLength: 12)
                    
                    PlaybackTitle()
                        .matchedGeometryEffect(id: "text", in: namespace!, properties: .frame, anchor: .center)
                    
                    Spacer(minLength: 12)
                    
                    PlaybackControls()
                        .transition(.move(edge: .bottom).combined(with: .opacity).animation(.snappy(duration: 0.1)))
                    
                    Spacer(minLength: 12)
                } else {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.snappy) {
                                viewModel.isQueueVisible.toggle()
                            }
                        } label: {
                            ItemImage(itemID: satellite.nowPlayingItemID, size: .regular, aspectRatio: .none, contrastConfiguration: nil)
                        }
                        .buttonStyle(.plain)
                        .frame(height: 72)
                        .shadow(color: .black.opacity(0.32), radius: 12)
                        .matchedGeometryEffect(id: "image", in: namespace!, properties: .frame, anchor: viewModel.isExpanded ? .topLeading : .topTrailing)
                        .modifier(PlaybackDragGestureCatcher(active: true))
                        
                        PlaybackTitle()
                            .modifier(PlaybackDragGestureCatcher(active: true))
                            .matchedGeometryEffect(id: "text", in: namespace!, properties: .frame, anchor: .center)
                    }
                    
                    PlaybackQueue()
                        .padding(.vertical, 12)
                        .frame(maxHeight: height - 140)
                        .transition(.move(edge: .bottom).combined(with: .opacity).animation(.snappy(duration: 0.1)))
                }
                
                PlaybackActions()
                    .transition(.move(edge: .bottom).combined(with: .opacity).animation(.snappy(duration: 0.1)))
                    .padding(.bottom, safeAreBottomInset + 12)
            }
        }
        .overlay(alignment: .top) {
            if viewModel.isExpanded {
                Button {
                    viewModel.isExpanded = false
                } label: {
                    Rectangle()
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 4)
                        .clipShape(.rect(cornerRadius: .infinity))
                }
                .buttonStyle(.plain)
                .padding(40)
                .contentShape(.rect)
                .modifier(PlaybackDragGestureCatcher(active: true))
                .padding(-40)
                .offset(y: safeAreTopInset)
                .transition(.asymmetric(insertion: .opacity.animation(.smooth.delay(0.3)), removal: .identity))
                .accessibilityLabel("action.dismiss")
            }
        }
        .padding(.horizontal, 28)
    }
}
private struct CollapsedForeground: View {
    @Environment(PlaybackViewModel.self) private var viewModel
    @Environment(Satellite.self) private var satellite
    @Environment(\.namespace) private var namespace
    
    var body: some View {
        Button {
            viewModel.isExpanded.toggle()
        } label: {
            HStack(spacing: 8) {
                if !viewModel.isExpanded {
                    ItemImage(itemID: satellite.nowPlayingItemID, size: .small, cornerRadius: 8)
                        .frame(width: 40, height: 40)
                        .matchedGeometryEffect(id: "image", in: namespace!, properties: .frame, anchor: .topLeading)
                    
                    Group {
                        if let currentItem = satellite.nowPlayingItem {
                            Text(currentItem.name)
                                .lineLimit(1)
                        } else {
                            Text("loading")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .matchedGeometryEffect(id: "text", in: namespace!, properties: .position, anchor: .center)
                } else {
                    Group {
                        Rectangle()
                            .frame(width: 40, height: 40)
                        
                        Text("loading")
                    }
                    .hidden()
                }
                
                Spacer()
                
                PlaybackBackwardButton()
                    .imageScale(.large)
                
                ZStack {
                    Group {
                        Image(systemName: "play.fill")
                        Image(systemName: "pause.fill")
                    }
                    .hidden()
                    
                    Group {
                        if let currentItemID = satellite.nowPlayingItemID, satellite.isLoading(observing: currentItemID) {
                            ProgressView()
                        } else if satellite.isBuffering || satellite.nowPlayingItemID == nil {
                            ProgressView()
                        } else {
                            Button {
                                satellite.togglePlaying()
                            } label: {
                                Label(satellite.isPlaying ? "playback.pause" : "playback.play", systemImage: satellite.isPlaying ? "pause.fill" : "play.fill")
                                    .labelStyle(.iconOnly)
                                    .contentTransition(.symbolEffect(.replace.byLayer.downUp))
                                    .animation(.spring(duration: 0.2, bounce: 0.7), value: satellite.isPlaying)
                            }
                        }
                    }
                    .transition(.blurReplace)
                }
                .imageScale(.large)
                .padding(.horizontal, 8)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .frame(height: 56)
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 8)
    }
}

#if DEBUG
#Preview {
    TabView {
        Tab(String(":)"), systemImage: "command") {
            NavigationStack {
                ZStack {
                    Rectangle()
                        .fill(.blue.opacity(0.6))
                        .ignoresSafeArea()
                    
                    Rectangle()
                        .fill(.yellow)
                    
                    Image(systemName: "command")
                }
            }
            .modifier(PlaybackTabContentModifier())
        }
    }
    .modifier(CompactPlaybackModifier(ready: true))
    .environment(\.playbackBottomOffset, 52)
    .previewEnvironment()
}
#endif
