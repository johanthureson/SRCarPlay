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
    @State private var duration = 0.0
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            HStack {
                Text("\(Int(currentTime)) s")
                Slider(value: $currentTime, in: 0...duration, onEditingChanged: sliderEditingChanged)
                Text("\(Int(duration - currentTime)) s left")
            }
            HStack {
                
                Button(action: {
                    player?.seek(to: CMTime(seconds: player?.currentTime().seconds ?? 0 - 5, preferredTimescale: 1))
                }) {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                }

                Button(action: {
                    player?.seek(to: .zero)
                    player?.play()
                    isPlaying = true
                }) {
                    Image(systemName: "gobackward")
                        .resizable()
                        .frame(width: 50, height: 50)
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
                    player?.seek(to: player?.currentItem?.asset.duration ?? .zero)
                }) {
                    Image(systemName: "goforward")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                
                Button(action: {
                    player?.seek(to: CMTime(seconds: player?.currentTime().seconds ?? 0 + 15, preferredTimescale: 1))
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
            duration = player?.currentItem?.asset.duration.seconds ?? 0
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
}
