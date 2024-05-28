//
//  PlayView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-04-01.
//

import SwiftUI
import AVFoundation

struct PlayView: View {
    
    var episodes: Episodes
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentTime = 0.0
    @State private var streamDuration = 0.0
    @State private var timer: Timer? = nil
    private let secondsBackward: Double = 5
    private let secondsForward: Double = 30

    var body: some View {
        VStack {
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
                .frame(height: 32)
            
            HStack(spacing: 20) {
                
                Button(action: {
                    player?.seek(to: .zero)
                    player?.play()
                    isPlaying = true
                }) {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                }

                Button(action: {
                    let cmTime = CMTime(seconds: (player?.currentTime().seconds ?? 0) - secondsBackward, preferredTimescale: 1)
                    player?.seek(to: cmTime)
                }) {
                    ZStack {
                        Image(systemName: "gobackward")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text(String(Int(secondsBackward)))
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
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                
                
                Button(action: {
                    print(player?.currentTime().seconds ?? 0)
                    player?.seek(to: CMTime(seconds: (player?.currentTime().seconds ?? 0) + secondsForward, preferredTimescale: 1))
                }) {
                    ZStack {
                        Image(systemName: "goforward")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text(String(Int(secondsForward)))
                            .offset(y: 2)
                    }

                }
                
                Button(action: {
                    player?.seek(to: player?.currentItem?.duration ?? .zero)
                }) {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
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
              let url = URL(string: urlString) else { return }
        
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = player?.currentTime().seconds ?? 0
            streamDuration = player?.currentItem?.duration.seconds ?? 0
            if streamDuration.isNaN {
                streamDuration = 0
            }
        }
    }
    
    private func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            player?.pause()
        } else {
            player?.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1))
            player?.play()
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
            return String(format: "%2d", s)
        }
        if h == 0 {
            return String(format: "%2d:%02d", m, s)
        }
        return String(format: "%d:%02d:%02d", h, m, s)
    }

}

#Preview {
    PlayView(episodes: Episodes())
}
