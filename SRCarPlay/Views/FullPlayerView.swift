//
//  FullPlayerView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-07-10.
//

import SwiftUI
import MediaPlayer

struct FullPlayerView: View {
    
    @Environment(PlayerModel.self) var playerModel
    @State private var currentTime = 0.0
    
    var body: some View {
        if let episodes = playerModel.episodes {
            VStack {
                if let imageUrl = episodes.imageurl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url)
                        .frame(width: 100, height: 100)
                        .aspectRatio(contentMode: .fit)
                }
                Text(episodes.title ?? "")
                    .font(.largeTitle)
                    .padding()
                Text(episodes.description ?? "")
                    .font(.subheadline)
                    .padding()
                VStack {
                    HStack {
                        Text("\(secondsToHoursMinutesSeconds(seconds: Int(currentTime)))")
                        Spacer()
                        Text("-\(secondsToHoursMinutesSeconds(seconds: Int(playerModel.streamDuration - currentTime)))")
                    }
                    
                    Slider(value: $currentTime, in: 0...playerModel.streamDuration, onEditingChanged: sliderEditingChanged)
                    
                }
                .padding()
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 0)
                
                HStack(spacing: 0) {
                    
                    Button(action: {
                        playerModel.player?.seek(to: .zero)
                        playerModel.player?.play()
                        playerModel.isPlaying = true
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 30))
                            .padding(playerModel.padding)
                    }
                    
                    Button(action: {
                        let cmTime = CMTime(seconds: (playerModel.player?.currentTime().seconds ?? 0) - playerModel.secondsBackward, preferredTimescale: 1)
                        playerModel.player?.seek(to: cmTime)
                    }) {
                        ZStack {
                            Image(systemName: "gobackward")
                                .font(.system(size: 45))
                                .padding(playerModel.padding)
                            Text(String(Int(playerModel.secondsBackward)))
                                .bold()
                                .offset(y: 2)
                        }
                    }
                    
                    Button(action: {
                        if playerModel.isPlaying {
                            playerModel.player?.pause()
                        } else {
                            playerModel.player?.play()
                        }
                        playerModel.isPlaying.toggle()
                    }) {
                        Image(systemName: playerModel.isPlaying ? "pause.circle" : "play.circle")
                            .font(.system(size: 60))
                            .padding(playerModel.padding)
                    }
                    
                    Button(action: {
                        playerModel.player?.seek(to: CMTime(seconds: (playerModel.player?.currentTime().seconds ?? 0) + playerModel.secondsForward, preferredTimescale: 1))
                    }) {
                        ZStack {
                            Image(systemName: "goforward")
                                .font(.system(size: 45))
                                .padding(playerModel.padding)
                            Text(String(Int(playerModel.secondsForward)))
                                .bold()
                                .offset(y: 2)
                        }
                    }
                    
                    Button(action: {
                        playerModel.player?.seek(to: playerModel.player?.currentItem?.duration ?? .zero)
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 30))
                            .padding(playerModel.padding)
                    }
                }
            }
            .navigationBarTitle(Text(episodes.title ?? ""), displayMode: .inline)
            .onAppear {
                play()
            }
            .onDisappear {
                playerModel.timer?.invalidate()
            }
        }
        
    }
    
    private func play() {
        guard let urlString = playerModel.episodes?.broadcast?.broadcastfiles?.first?.url,
              let audioURL = URL(string: urlString) else { return }
        
        if playerModel.player == nil {
            playerModel.player = AVPlayer(url: audioURL)
        }
        playerModel.player?.play()
        playerModel.isPlaying = true
        
        playerModel.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = playerModel.player?.currentTime().seconds ?? 0
            guard let seconds = playerModel.player?.currentItem?.duration.seconds else {
                playerModel.streamDuration = 0
                return
            }
            if seconds.isNaN {
                playerModel.streamDuration = 0
            } else {
                playerModel.streamDuration = seconds
            }
        }
    }
    
    private func sliderEditingChanged(editingStarted: Bool) {
        if playerModel.timeControlStatus == nil {
            playerModel.timeControlStatus = playerModel.player?.timeControlStatus
        }
        if editingStarted {
            playerModel.player?.pause()
        } else {
            playerModel.player?.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1))
            if playerModel.timeControlStatus == .playing {
                playerModel.player?.play()
            }
            playerModel.timeControlStatus = nil
        }
    }
    
    private func secondsToHoursMinutesSeconds (seconds : Int) -> (String) {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = (seconds % 3600) % 60
        return formatDuration(h: h, m: m, s: s)
    }
    
    private func formatDuration(h: Int, m: Int, s: Int) -> String {
        if m == 0 {
            return "00:" + String(format: "%02d", s)
        }
        if h == 0 {
            return String(format: "%02d:%02d", m, s)
        }
        return String(format: "%d:%02d:%02d", h, m, s)
    }
}
