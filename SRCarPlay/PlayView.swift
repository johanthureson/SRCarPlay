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

    var body: some View {
        VStack {
            Text("Hello, World!")
            HStack {
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
                    player?.seek(to: CMTime(seconds: player?.currentTime().seconds ?? 0 - 5, preferredTimescale: 1))
                }) {
                    Image(systemName: "backward.fill")
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
                    player?.seek(to: CMTime(seconds: player?.currentTime().seconds ?? 0 + 15, preferredTimescale: 1))
                }) {
                    Image(systemName: "forward.fill")
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
            }
        }
        .navigationBarTitle(Text(episodes.title ?? ""), displayMode: .inline)
        .onAppear {
            play()
        }
    }
    
    private func play() {
        guard let urlString = episodes.broadcast?.broadcastfiles?.first?.url,
              let url = URL(string: urlString) else { return }
        
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
    }
}
