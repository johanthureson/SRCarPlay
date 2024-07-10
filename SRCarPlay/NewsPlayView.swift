//
//  NewsPlayView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-04-01.
//

import SwiftUI
import AVFoundation

struct NewsPlayView: View {
    
    var episodes: Episodes
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentTime = 0.0
    @State private var streamDuration = 0.0
    @State private var timer: Timer? = nil
    private let secondsBackward: Double = 5
    private let secondsForward: Double = 30
    private let padding: CGFloat = 5
    @State private var timeControlStatus: AVPlayer.TimeControlStatus?

    var body: some View {
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
                    Text("-\(secondsToHoursMinutesSeconds(seconds: Int(streamDuration - currentTime)))")
                }

                Slider(value: $currentTime, in: 0...streamDuration, onEditingChanged: sliderEditingChanged)

            }
            .padding()
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 0)
            
            HStack(spacing: 0) {
                
                Button(action: {
                    player?.seek(to: .zero)
                    player?.play()
                    isPlaying = true
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 30))
                        .padding(padding)
                }

                Button(action: {
                    let cmTime = CMTime(seconds: (player?.currentTime().seconds ?? 0) - secondsBackward, preferredTimescale: 1)
                    player?.seek(to: cmTime)
                }) {
                    ZStack {
                        Image(systemName: "gobackward")
                            .font(.system(size: 45))
                            .padding(padding)
                        Text(String(Int(secondsBackward)))
                            .bold()
                            .offset(y: 2)
                    }
                }
                
                Button(action: {
                    if isPlaying {
                        player?.pause()
                    } else {
                        player?.play()
                    }
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                        .font(.system(size: 60))
                        .padding(padding)
                }
                
                Button(action: {
                    player?.seek(to: CMTime(seconds: (player?.currentTime().seconds ?? 0) + secondsForward, preferredTimescale: 1))
                }) {
                    ZStack {
                        Image(systemName: "goforward")
                            .font(.system(size: 45))
                            .padding(padding)
                        Text(String(Int(secondsForward)))
                            .bold()
                            .offset(y: 2)
                    }
                }
                
                Button(action: {
                    player?.seek(to: player?.currentItem?.duration ?? .zero)
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 30))
                        .padding(padding)
                }
            }
        }
        .navigationBarTitle(Text(episodes.title ?? ""), displayMode: .inline)
        .onAppear {
            play()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func play() {
        guard let urlString = episodes.broadcast?.broadcastfiles?.first?.url,
              let audioURL = URL(string: urlString) else { return }
        
        if player == nil {
            player = AVPlayer(url: audioURL)
        }
        player?.play()
        isPlaying = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = player?.currentTime().seconds ?? 0
            guard let seconds = player?.currentItem?.duration.seconds else {
                streamDuration = 0
                return
            }
            if seconds.isNaN {
                streamDuration = 0
            } else {
                streamDuration = seconds
            }
        }
    }
    
    private func sliderEditingChanged(editingStarted: Bool) {
        if timeControlStatus == nil {
            timeControlStatus = player?.timeControlStatus
        }
        if editingStarted {
            player?.pause()
        } else {
            player?.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1))
            if timeControlStatus == .playing {
                player?.play()
            }
            timeControlStatus = nil
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

#Preview {
    NewsPlayView(episodes: Episodes())
}
